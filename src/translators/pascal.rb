require_relative 'abstract_translator'

module Translators
  #
  # SplashKit C Library code generator
  #
  class Pascal < AbstractTranslator
    def initialize(data, logging)
      super(data, logging)
      @direct_types = []
    end

    self.case_converters = {
      types:      :pascal_case,
      functions:  :pascal_case,
      variables:  :camel_case
    }

    def render_templates
      {
        'splashkit.pas' => read_template('splashkit.pas')
      }
    end

    #=== internal ===

    private

    #
    # Converts SK type to Pascal type
    #
    def pascal_type_for(type_name)
      {
        'int'       => 'LongInt',
        'short'     => 'ShortInt',
        'long'      => 'Int64',
        'float'     => 'Single',
        'double'    => 'Double',
        'byte'      => 'Char',
        'char'      => 'Char',
        'bool'      => 'LongInt',
        'enum'      => 'LongInt',
        'struct'    => "__sklib_#{type_name}",
        'string'    => '__sklib_string',
        'typealias' => "__sklib_#{type_name}"
      }[raw_type_for(type_name)]
    end

    #
    # Generate a Pascal type signature from a SK function
    #
    def pascal_signature_for(function, is_lib_func = false)
      declaration = is_proc?(function) ? 'procedure' : 'function'
      name =
        if is_lib_func
          CLib.lib_function_name_for(function)
        else
          function[:name].function_case
        end
      param_list = pascal_parameter_list_for(function)
      func_suffix =
        if is_proc?(function)
          ": #{pascal_type_for(function[:return_type])}"
        end
      "#{declaration} #{name}(#{param_list})#{func_suffix};"
    end

    #
    # Generate a lib type signature from a SK function
    #
    def lib_signature_for(function)
      pascal_signature_for(function, true)
    end

    #
    # Convert a list of parameters to a Pascal parameter list
    #
    def pascal_parameter_list_for(function)
      function[:parameters].map do |param_name, param_data|
        type = pascal_type_for param_data
        var =
          if param_data[:is_reference]
            param_data[:is_const] ? 'const ' : 'var '
          end
        type = "^#{type}" if param_data[:is_pointer]
        "#{var}#{param_name.variable_case}: #{type}"
      end.join('; ')
    end

    #
    # Generates a field's struct information
    #
    def pascal_struct_field_for(field_name, field_data)
    end

    #
    # C Lib type to Pascal type mapper
    #
    def pascal_mapper_fn_for(function)
    end

    #
    # C Lib type to Pascal updater
    #
    def cpp_update_fn_for(function)
    end
  end
end
