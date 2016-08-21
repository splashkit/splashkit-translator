module Generators
  #
  # Common helper methods for generators
  #
  class AbstractGenerator
    require 'erb'
    # Plucking for arrays of hashes
    require_relative '../../lib/core_ext/array.rb'

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

    private

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
    def read_res_file(file_name)
      file = File.new "#{generator_res_dir}/#{file_name}", 'r'
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
      template = read_res_file(File.basename(files.first)).strip
      ERB.new(template, nil, '>').result(binding)
    end
  end
end
