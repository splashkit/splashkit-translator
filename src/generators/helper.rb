module Generators
  #
  # Common helper methods for generators
  #
  module Helper
    # Plucking for arrays of hashes
    require_relative '../../lib/core_ext/array.rb'
    # For indent method
    require_relative '../../lib/core_ext/string.rb'

    #
    # Initializes the generator with the data and source directories provided
    #
    def initialize(data, src)
      @data = data
      @src = File.dirname src
    end

    #
    # Executes the generator on the template file, returning a string result
    #
    def execute
      puts "Executing #{name} generator..."
      template = read_template
      result = String.new template
      template.gsub(template_method_flags) do |method_flag|
        method = method_for_template_flag method_flag
        puts "-> Running replacement for #{method}..."
        replace_with = send(method)
        result.gsub!(method_flag, replace_with)
      end
      puts '-> Done!'
      result
    end

    private

    #
    # Gets the full name of the class
    #
    def name
      self.class.name
    end

    #
    # Gets the executing module's name
    #
    def generator_name
      name.to_s.split('::').last.downcase
    end

    #
    # Returns the generator's resource directory
    #
    def generator_res_dir
      File.expand_path('../../../res/generators', __FILE__) + '/' + generator_name
    end

    #
    # Reads a file defined by res/generators/{generator_name}/{file_name}
    #
    def read_res_file(file_name)
      file = File.new "#{generator_res_dir}/#{file_name}", 'r'
      file.readlines.join
    ensure
      file.close
    end

    #
    # Substitute generator data in where variables are placed
    #
    def sub_template_data(template, data)
      return template if data.empty?
      result = String.new template
      regex = %r{(?:\/\*|\'{3})=([^\*\']+)(?:\*\/|'{3})}
      template.gsub(regex) do |var_flag|
        _, var_name = *(regex.match var_flag)
        sub_value = data[var_name.to_sym]
        unless sub_value.is_a? String
          raise "Variable substitution for #{var_name} must be a string (got `#{sub_value.inspect}')"
        end
        result.gsub!(var_flag, sub_value)
      end
      result
    end

    #
    # Reads a generator's template file (defaults to the primary template file)
    # Insert supplied data in multi-line comments supplied with equal
    #   my_function /*=foo_bar */  c-style
    #   my_function '''=foo_bar''' python
    #
    def read_template(name = generator_name, data = {})
      # Don't know the extension, but if it's module.tpl.* then it's the primary
      # template file
      path = "#{generator_res_dir}/#{name}.tpl*"
      files = Dir[path]
      raise "No template files found under #{path}" if files.empty?
      raise "Need exactly one match for #{path}" if files.length > 1
      template = read_res_file File.basename files.first
      sub_template_data(template, data).strip
    end

    #
    # Template files have method flags to indicate where ruby methods
    # should be called and whose outputs should be inserted
    #
    def template_method_flags
      /^\[#{Regexp.escape name}\.([a-z\_]+)\]$/m
    end

    #
    # Returns the method symbol for the template flag provided, or raises
    # an exception where no such symbol exists in the module
    #
    def method_for_template_flag(flag)
      method_name = flag.match(template_method_flags).captures.first.to_sym
      raise "No method `#{method_name}' exists in #{name}" unless methods.include? method_name
      method_name
    end
  end
end
