module Generators
  #
  # Common helper methods for generators
  #
  module Helper
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
      result = read_template
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
    # Reads a generator's template file (defaults to the primary template file)
    #
    def read_template(name = generator_name)
      # Don't know the extension, but if it's module.tpl.* then it's the primary
      # template file
      path = "#{generator_res_dir}/#{name}.*.erb"
      files = Dir[path]
      raise "No template files found under #{path}" if files.empty?
      raise "Need exactly one match for #{path}" if files.length > 1
      template = read_res_file(File.basename(files).first).strip
      ERB.new(template).result
    end

    def attr_readers(attribute_name, *list_of_aliases)
      list_of_aliases.each do |aliass|
        define_method(aliass) do
          instance_variable_get("@#{attribute_name}")
        end
      end
    end
  end
end
