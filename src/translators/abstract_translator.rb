module Translators
  #
  # Gets all translators
  #
  def all
    Translators.constants
               .select { |c| Class === Translators.const_get(c) }
               .select { |c| ![:Namespace, :AbstractTranslator, :ReusableCAdapter].include? c }
               .map { |t| [t.upcase, Translators.const_get(t)] }
               .to_h
  end
  def adapters
    all.select { |c| ![:CLIB, :DOCS].include? c }.values
  end
  module_function :all
  module_function :adapters

  #
  # Namespace for dynamic binding in ERBs
  #
  class Namespace
    def initialize(hash)
      hash.each do |key, value|
        singleton_class.send(:define_method, key) { value }
      end
    end

    def get_binding
      binding
    end
  end

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
    def initialize(input, logging = false)
      if input.include? :data
        @data = input[:data]
      else
        @data = input
      end

      @logging = logging
      @direct_types = []
      @enums = @data[:enums] || @data.values.pluck(:enums).flatten
      @classes = input[:classes]
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
      # Define case converters
      define_case_converters()
    end

    #
    # Dynamically adds the case conversion functions using the right types
    #
    def define_case_converters
      const_key = "#{name.upcase}_IDENTIFIER_CASES".to_sym
      converters =
        if self.class.const_defined?(const_key)
          self.class.const_get(const_key)
        else
          # Default to snake case
          converters = {
            types:      :snake_case,
            functions:  :snake_case,
            variables:  :snake_case,
            constants:  :upper_case,
            fields:     :snake_case
          }
        end
      string_case_module = Module.new do
        def send_case_conversion_method(casee)
          send("to_#{casee}".to_sym)
        end
        define_method(:type_case) do
          to_s.send_case_conversion_method converters[:types]
        end
        define_method(:function_case) do
          to_s.send_case_conversion_method converters[:functions]
        end
        define_method(:variable_case) do
          to_s.send_case_conversion_method converters[:variables]
        end
        define_method(:constant_case) do
          to_s.send_case_conversion_method converters[:constants]
        end
        define_method(:field_case) do
          to_s.send_case_conversion_method converters[:fields]
        end
      end
      string_case_module.freeze
      String.prepend string_case_module
      Symbol.prepend string_case_module
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
    # Return true iff function provided is void
    #
    def is_proc?(function)
      function[:return][:type] == 'void' && !function[:return][:is_pointer]
    end

    #
    # Return true iff function provided is returning function
    #
    def is_func?(function)
      !is_proc?(function)
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
    def read_template(name = self.name, namespace = nil)
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

      ERB.new(template, nil, '>').result(namespace.nil? ? binding : namespace.get_binding )
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
    # Type is unsigned
    #
    def unsigned_type?(type_data)
      !(type_data[:type] =~ /^unsigned\s+\w+/).nil?
    end

    #
    # Type is a char pointer
    #
    def char_pointer?(type_data)
      type_data[:type] == 'char' && type_data[:is_pointer]
    end

    #
    # Type is a void pointer
    #
    def void_pointer?(type_data)
      type_data[:type] == 'void' && type_data[:is_pointer]
    end

    #
    # Type is a function pointer
    #
    def function_pointer?(type_data)
      @function_pointers.pluck(:name).include? type_data[:type]
    end

    #
    # Type is a vector
    #
    def vector_type?(type_data)
      type_data[:is_vector]
    end

    #
    # Array is one dimensional
    #
    def array_is_1d?(array_data)
      array_data[:array_dimension_sizes].size == 1
    end

    #
    # Array is two dimensional
    #
    def array_is_2d?(array_data)
      array_data[:array_dimension_sizes].size == 2
    end

    #
    # Returns the size of a N-dimensional array represented as a single
    # dimensional array. E.g., if we have foo[3][3] -> foo[9] (i.e., 3 * 3)
    #
    def array_size_as_one_dimensional(array_data)
      array_data[:array_dimension_sizes].inject(:*)
    end

    #
    # Returns the index either as a one dimensional index (array with one
    # element) or two dimensional index (array with two elements) depending on
    # the data provided
    #
    def array_index_from_one_dimensional_index(array_data, idx)
      if array_is_2d?(array_data)
        c = array_data[:array_dimension_sizes][1] # 3
        [(idx / c).to_i, idx % c]
      else
        idx
      end
    end

    #
    # Converts library 1D index for an array into its 1D/2D equivalent
    # depending on the array_data
    #
    def array_mapper_index_for(array_data, lib_idx)
      new_idx = array_index_from_one_dimensional_index(array_data, lib_idx)
      if array_is_2d?(array_data)
        array_at_index_syntax(new_idx.first, new_idx.last)
      else
        array_at_index_syntax(new_idx)
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
      if type_data[:type] == 'string'
        raise Parser::Error, 'At this stage we cant handle string passed by ref'
      end
      !type_data[:is_vector]
    end

  end
end
