module Generators
  module Helper
    #
    # Executes the generator on the template file, returning a string result
    #
    def execute
      puts "Executing #{name} generator..."
      template = read_template
      result = String.new template
      template.gsub(template_method_flags) do |flag|
        method = method_for_template_flag flag
        puts "-> Running replacement for #{method}..."
        replace_with = send(method)
        result.gsub!(flag, replace_with)
      end
      puts "-> Done!"
      result
    end

    #
    # Gets the executing module's name
    #
    def module_name
      name.to_s.split('::').last.downcase
    end

    #
    # Returns the module's resource directory
    #
    def module_res_dir
      File.expand_path('../../../res/generators', __FILE__) + '/' + module_name
    end

    #
    # Reads a file defined by res/generators/{module_name}/{file_name}
    #
    def read_res_file(file_name)
      file = File.new "#{module_res_dir}/#{file_name}", 'r'
      file.readlines.join
    ensure
      file.close
    end

    #
    # Reads a generator's template file (defaults to the primary template file)
    #
    def read_template(name = module_name)
      # Don't know the extension, but if it's module.tpl.* then it's the primary
      # template file
      path = "#{module_res_dir}/#{name}.tpl.*"
      files = Dir[path]
      raise "No template files found under #{path}" if files.empty?
      raise "Need exactly one match for #{path}" if files.length > 1
      read_res_file File.basename files.first
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
