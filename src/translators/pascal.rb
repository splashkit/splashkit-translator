require_relative 'abstract_translator'
require_relative 'translator_helper'

module Translators
  #
  # SplashKit C Library code generator
  #
  class Pascal < AbstractTranslator
    include TranslatorHelper

    def initialize(data, logging)
      super(data, logging)
    end

    def render_templates
      {
        'splashkit.pas' => read_template('splashkit.pas')
      }
    end

    #=== internal ===

    PASCAL_IDENTIFIER_CASES = {
      types:      :pascal_case,
      functions:  :pascal_case,
      variables:  :camel_case
    }
    DIRECT_TYPES = {
      'int'             => 'Integer',
      'short'           => 'ShortInt',
      'long'            => 'Int64',
      'float'           => 'Single',
      'double'          => 'Double',
      'byte'            => 'Char',
      'char'            => 'Char',
      'unsigned char'   => 'Char',
      'unsigned int'    => 'Cardinal',
      'unsigned short'  => 'Word',
      'unsigned long'   => 'Longword'
    }
    SK_TYPES_TO_PASCAL_TYPES = {
      'bool'      => 'Boolean',
      'string'    => 'String'
    }
    SK_TYPES_TO_LIB_TYPES = {
      'bool'      => 'LongInt',
      'enum'      => 'LongInt'
    }

    def type_exceptions(type_data)
      # Handle char* as PChar
      return 'PChar' if char_pointer?(type_data)
      # Handle void * as Pointer
      return 'Pointer' if void_pointer?(type_data)
      # Handle function pointers
      return 'TODO' if function_pointer?(type_data)
      # Handle vectors as Array of <T>
      return "Array of #{type_data[:type_parameter]}" if vector_type?(type_data)
    end

    #
    # Generate a Pascal type signature from a SK function
    #
    def signature_syntax(function, function_name, parameter_list)
      declaration = is_proc?(function) ? 'procedure' : 'function'
      func_suffix = ": #{sk_type_for(function[:return])}" if is_func?(function)
      "#{declaration} #{function_name}(#{parameter_list})#{func_suffix}"
    end

    #
    # Convert a list of parameters to a Pascal parameter list
    # Use the type conversion function to get which type to use
    # as this function is used to for both Library and Front-End code
    #
    def parameter_list_syntax(parameters, type_conversion_fn)
      parameters.map do |param_name, param_data|
        type = send(type_conversion_fn, param_data)
        if param_data[:is_reference]
          var = param_data[:is_const] ? 'const ' : 'var '
        end
        type = "^#{type}" if param_data[:is_pointer]
        "#{var}#{param_name.variable_case}: #{type}"
      end.join('; ')
    end

    def lib_argument_list_for(function)
      function[:parameters].map do |param_name, param_data|
        address_of_oper = '@' if param_data[:is_reference] && !param_data[:is_const]
        "#{address_of_oper}__skparam__#{param_name}"
      end.join(', ')
    end

    #
    # Generates a field's struct information
    #
    def sk_struct_field_for(field_name, field_data)
      type = pascal_type_for field_data
      type = "^#{type}" if field_data[:is_pointer]
      if field_data[:is_array]
        array_dims = field_data[:array_dimension_sizes]
        array_decl =
          if array_dims.length == 1
            "[0..#{array_dims.first}]"
          else
            "[0..#{array_dims.first}, 0..#{array_dims.last}]"
          end
        array_decl = "Array #{array_decl} of #{type}"
      end
      "#{field_name}: #{type}"
    end
  end
end
