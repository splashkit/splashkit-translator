module Generators
  #
  # Common helper methods for generators
  #
  class AbstractGenerator
    require 'erb'
    # Indentation helper
    require_relative '../../lib/core_ext/string.rb'
    # Plucking for arrays of hashes
    require_relative '../../lib/core_ext/array.rb'

    #
    # Initializes the generator with the data and source directories provided
    #
    def initialize(data, src)
      @data = data
      @src = src
      @enums = @data.values.pluck(:enums).flatten
      @typealiases = @data.values.pluck(:typedefs).flatten
      @structs = @data.values.pluck(:structs).flatten
      @functions = @data.values.pluck(:functions).flatten
    end

    #
    # Executes the generator on the template file, returning a string result
    #
    def execute
      puts "Executing #{name} generator..."
      execute_result = render_templates
      puts '-> Done!'
      execute_result
    end

    #
    # Gets the full name of the generator
    #
    def name
      self.class.name.to_s.split('::').last.downcase
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

    private

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
      function[:return_type] == 'void'
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
    # Returns the generator's resource directory
    #
    def generator_res_dir
      File.expand_path('../../../res/generators', __FILE__) + '/' + name
    end

    #
    # Reads a file defined by res/generators/{generator_name}/{file_name}
    #
    def read_res_file(file_path)
      file = File.new file_path, 'r'
      file.readlines.join
    ensure
      file.close
    end

    #
    # Reads a generator's template file (defaults to the primary template file)
    #
    def read_template(name = self.name)
      # Don't know the extension, but if it's module.tpl.* then it's the primary
      # template file
      path = "#{generator_res_dir}/#{name}.*.erb"
      files = Dir[path]
      raise "No template files found under #{path}" if files.empty?
      raise "Need exactly one match for #{path}" unless files.length == 1
      template = read_res_file(files.first).strip
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
  end
end
