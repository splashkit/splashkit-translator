module Translators
  #
  # Common helper methods for translators
  #
  class AbstractTranslator
    require 'erb'
    # Access to config vars
    require_relative '../config'
    extend Config
    # Indentation helper
    require_relative '../../lib/core_ext/string'
    # Plucking for arrays of hashes
    require_relative '../../lib/core_ext/array'

    #
    # Initializes the translator with the data and source directories provided
    #
    def initialize(data, src, logging)
      @data = data
      @src = src
      @logging = logging
      @direct_types = []
      @enums = @data[:enums] || @data.values.pluck(:enums).flatten
      @typealiases =
        (@data[:typedefs] || @data.values.pluck(:typedefs).flatten).select do |td|
          !td[:is_function_pointer]
        end
      @function_pointers =
        (@data[:typedefs] || @data.values.pluck(:typedefs).flatten).select do |td|
          td[:is_function_pointer]
        end
      @structs = @data[:structs] || @data.values.pluck(:structs).flatten
      @functions = @data[:functions] || @data.values.pluck(:functions).flatten
      @defines = @data[:defines] || @data.values.pluck(:defines).flatten
      @vector_types =
        @functions
        .map { |fn| fn[:return] }                       # Return types...
        .select { |rettype| rettype [:is_vector] }      # that are vectors
        .concat(
          @functions
          .map { |fn| fn[:parameters].values }.flatten  # Parameter types...
          .select { |param| param[:is_vector] }         # that are vectors
        )
        .map { |param| param[:type_parameter] }         # Map to their type
        .uniq                                           # unique type params
    end

    #
    # Ensure our structs are ordered. Must do this here so we have
    # @direct_types defined with some overidden data
    #
    class << self
      alias _new :new
      def new(*args)
        inst = _new(*args)
        inst.instance_variable_set(:@structs, inst.ordered_structs)
        inst
      end
    end

    #
    # Executes the translator on the template file, returning a string result
    #
    def execute
      puts "Executing #{name} translator..."
      execute_result = render_templates
      puts 'Done!'
      execute_result
    end

    #
    # Override this method in the child class to do something once the
    # execution is complete
    #
    def post_execute
    end

    #
    # Gets the full name of the translator
    #
    def name
      self.class.name.to_s.split('::')[1].downcase
    end

    #
    # Dynamically adds the case conversion functions using the right types
    # assigned by self.case_converters
    #
    def self.case_converters=(converters)
      string_case_module = Module.new do
        def send_case_conversion_method(casee)
          send("to_#{casee}".to_sym)
        end
        define_method(:type_case) do
          send_case_conversion_method converters[:types]
        end
        define_method(:function_case) do
          send_case_conversion_method converters[:functions]
        end
        define_method(:variable_case) do
          send_case_conversion_method converters[:variables]
        end
      end
      string_case_module.freeze
      String.prepend string_case_module
    end

    private_class_method :"case_converters="

    #
    # Returns the structs ordered by dependency between other structs
    #
    def ordered_structs
      # What types do I know of
      knows_of = @direct_types + @typealiases.pluck(:name) + @enums.pluck(:name)
      unordered_structs = @structs
      result = []
      unordered_structs.each do |struct|
        struct[:fields].each do |_, field_data|
          field_type = field_data[:type]
          field_struct = unordered_structs.select { |s| s[:name] == field_type }.first
          # This is a struct type I know about already...
          next if knows_of.include?(field_type) || field_struct.nil?
          result << field_struct
          knows_of << field_type
        end
        # Skip this struct if was already added by a field
        next if knows_of.include?(struct[:name])
        result << struct
        knows_of << struct[:name]
      end
      result
    end

    protected

    #
    # Default case types are snake_case, unless it is overridden in a subclass
    #
    self.case_converters = {
      types:      :snake_case,
      functions:  :snake_case,
      variables:  :snake_case
    }

    #
    # Return true iff function provided is void
    #
    def is_void?(function)
      function[:return][:type] == 'void' && !function[:return][:is_pointer]
    end

    #
    # Called under `execute` to render templates. Should return a hash
    # with the intended filename as the key and its contents as the value
    #
    def render_templates
      raise NotImplementedError
    end

    #
    # Alias of attr_reader but allows multiple aliases to be used
    #
    def self.attr_readers(attribute_name, *list_of_aliases)
      list_of_aliases.each do |aliass|
        define_method(aliass) do
          instance_variable_get("@#{attribute_name}")
        end
      end
    end

    #
    # Returns the translator's resource directory
    #
    def translator_res_dir
      File.expand_path('../../../res/translators', __FILE__) + '/' + name
    end

    #
    # Reads a file defined by res/translators/{translator_name}/{file_name}
    #
    def read_res_file(file_path)
      file = File.new file_path, 'r'
      file.readlines.join
    ensure
      file.close
    end

    #
    # Reads a translator's template file (defaults to the primary template file)
    #
    def read_template(name = self.name)
      # Don't know the extension, but if it's module.tpl.* then it's the primary
      # template file
      puts "Running template #{name}..." if @logging
      # Don't prepend .* unless extension is specified
      filename = name =~ /\.\w+$/ ? name : "#{name}.*"
      path = "#{translator_res_dir}/#{filename}.erb"
      files = Dir[path]
      raise "No template files found under #{path}" if files.empty?
      raise "Need exactly one match for #{path}" unless files.length == 1
      template = read_res_file(files.first).strip << "\n"
      ERB.new(template, nil, '>').result(binding)
    end

    #
    # Attempts to lookup a raw type for the provided type
    #
    def raw_type_for(type)
      if @typealiases.pluck(:name).include? type
        'typealias'
      elsif @structs.pluck(:name).include? type
        'struct'
      elsif @enums.pluck(:name).include? type
        'enum'
      else
        type
      end
    end

    #
    # On an update of a ref parameter:
    #
    # Check if the type can be copied across the boundary directly. This will
    # include the primitive types. These can just be directly assigned to the
    # parameter in the adapter. So...
    #
    # - The library can directly assign a value to the parameter pointer
    # - The adapter can just copy the value in the parameter copy to the
    #   original parameter.
    #
    # But.. if this is false, it means that you cant just copy this directly
    # across. Why? Its a dynamic array. The adapter will need to free the
    # original dynamic array, so we need to update the original array. This will
    # then pass back data in the `from_lib` fields of the struct, leaving the
    # `from_app` fields untouched. So...
    #
    # - The library needs to use update to malloc into the `from_lib` fields.
    # - The adapter will need to update the original vector/dynamic array. The
    #   size may have changed, the values may have changed.
    #
    def type_can_be_directly_copied?(type_data)
      if type_data[:type] == "string"
        raise Parser::Error, "At this stage we cant handle string passed by ref"
      end

      return ( ! type_data[:is_vector] )
    end

  end
end
