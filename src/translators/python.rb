require_relative 'abstract_translator'
require_relative 'translator_helper'

module Translators
  #
  # SplashKit C Library code generator
  #
  class Python < AbstractTranslator
    include TranslatorHelper

    def initialize(data, logging = false)
      super(data, logging)
    end

    def render_templates
      {
        'splashkit.py' => read_template('splashkit.py')
      }
    end

    #=== internal ===

    PYTHON_IDENTIFIER_CASES = {
      types:      :pascal_case,
      functions:  :snake_case,
      variables:  :snake_case,
      fields:     :snake_case,
      constants:  :snake_case
    }
    DIRECT_TYPES = {
      'int'             => 'c_int',
      'short'           => 'c_short',
      'int64_t'         => 'c_int64',
      'float'           => 'c_float',
      'double'          => 'c_double',
      'int8_t'          => 'c_byte',
      'byte'            => 'c_byte',
      'unsigned int'    => 'c_uint',
      'unsigned short'  => 'c_ushort'
    }
    SK_TYPES_TO_PYTHON_TYPES = {
      'bool'      => 'bool',
      'string'    => 'str',
      'char'      => 'char',
      'unsigned char'   => 'ubyte',
    }
    SK_TYPES_TO_LIB_TYPES = {
      'string'    => '_sklib_string',
      'bool'      => 'c_bool',
      'char'      => 'c_char',
      'enum'      => 'c_int',
      'unsigned char'   => 'c_ubyte',
      'typealias' => 'c_void_p',
    }

    # Override to switch to single _ to avoid issues with Python
    def sklib_prefix
      "_sklib"
    end

    def type_exceptions(type_data, type_conversion_fn, opts = {})
      # # Handle char* as PChar
      # return 'PChar' if char_pointer?(type_data)
      # Handle void * as Pointer
      return 'c_void_p' if void_pointer?(type_data)
      # Handle function pointers
      return type_data[:type].type_case if function_pointer?(type_data)
      # # Handle generic pointer
      # return "^#{type}" if type_data[:is_pointer]
      # # Handle vectors as Array of <T>
      if vector_type?(type_data)
        return "_sklib_vector_#{type_data[:type_parameter]}" if opts[:is_lib]
        return "ArrayOf#{send(type_conversion_fn, type_data[:type_parameter])}"
      end
      # No exception for this type
      return nil
    end

    #
    # Generate a Python type signature from a SK function
    #
    def signature_syntax(function, function_name, parameter_list, return_type, opts = {})
      if opts[:is_lib]
        declaration = is_proc?(function) ? 'procedure' : 'function'
        func_suffix = ": #{return_type}" if is_func?(function)
        "splashkit.#{function_name}.argtypes = [#{parameter_list}]"
      else
        declaration = is_proc?(function) ? 'procedure' : 'function'
        func_suffix = ": #{return_type}" if is_func?(function)
        "#{declaration} #{function_name}(#{parameter_list})#{func_suffix}"
      end
    end

    def sk_function_name_for(function)
      "#{function[:name].function_case}#{function[:attributes][:suffix].nil? ? '':'_'}#{function[:attributes][:suffix]}"
    end

    def sk_signature_for(function)
      name            = sk_function_name_for(function)
      parameter_list  = function[:parameters].map do |param_name, param_data| param_name end.join(', ')
      "def #{name}(#{parameter_list}):"
    end

    #
    # Convert a list of parameters to a Pascal parameter list
    # Use the type conversion function to get which type to use
    # as this function is used to for both Library and Front-End code
    #
    def parameter_list_syntax(parameters, type_conversion_fn, opts = {})
      parameters.map do |param_name, param_data|
        type = send(type_conversion_fn, param_data)
        # if param_data[:is_reference]
        #   var = param_data[:is_const] ? 'const ' : 'var '
        # end
        # "#{var}#{param_name.variable_case}: #{type}"
        if opts[:is_lib]
          if param_data[:is_reference] && !param_data[:is_const]
            "POINTER(#{type})"
          else
            "#{type}"
          end
        else
        end
      end.join(', ')
    end

    def argument_list_syntax(arguments)
      args = arguments.map do |arg_data| arg_data[:name]
        if arg_data[:param_data][:is_reference] && !arg_data[:param_data][:is_const]
          "byref(#{arg_data[:name]})"
        else
          arg_data[:name]
        end
      end

      args.join(', ')
    end

    #
    # Syntax for declaring array
    #
    def array_declaration_syntax(array_type, dim1_size, dim2_size = nil)
      if dim2_size.nil?
        "#{array_type} * #{dim1_size}"
      else
        "(#{array_type} * #{dim2_size}) * #{dim1_size}"
      end
    end

    #
    # Syntax for accessing array
    #
    def array_at_index_syntax(idx1, idx2 = nil)
      if idx2.nil?
        "[#{idx1}]"
      else
        "[#{idx1}][#{idx2}]"
      end
    end
  end
end
