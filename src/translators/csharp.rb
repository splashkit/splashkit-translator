require_relative 'abstract_translator'
require_relative 'translator_helper'

module Translators
  #
  # SplashKit C# Library code generator
  #
  class CSharp < AbstractTranslator
    include TranslatorHelper

    def initialize(data, logging = false)
      super(data, logging)
    end

    def render_templates
      {
        'SplashKit.cs' => read_template('SplashKit.cs')
      }
    end

    #=== internal ===

    CSHARP_IDENTIFIER_CASES = {
      types:      :pascal_case,
      functions:  :pascal_case,
      variables:  :camel_case,
      constants:  :upper_case
    }
    DIRECT_TYPES = {
      'int'             => 'int',
      'short'           => 'short',
      'int64_t'         => 'long',
      'float'           => 'float',
      'double'          => 'double',
      'byte'            => 'byte',
      'char'            => 'char',
      'unsigned char'   => 'byte',
      'unsigned int'    => 'uint',
      'unsigned short'  => 'ushort'
    }
    SK_TYPES_TO_CSHARP_TYPES = {
      'bool'      => 'bool',
      'string'    => 'String'
    }
    SK_TYPES_TO_LIB_TYPES = {
      'bool'      => 'int',
      'enum'      => 'int'
    }

    def type_exceptions(type_data, type_conversion_fn, opts = {})
      # Handle char* as PChar
      return 'PChar' if char_pointer?(type_data)
      # Handle void * as Pointer
      return 'Pointer' if void_pointer?(type_data)
      # Handle function pointers
      return type_data[:type].type_case if function_pointer?(type_data)
      # Handle generic pointer
      return "^#{type}" if type_data[:is_pointer]
      # Handle vectors as Array of <T>
      if vector_type?(type_data)
        return "__sklib_vector_#{type_data[:type_parameter]}" if opts[:is_lib]
        return "List<#{send(type_conversion_fn, type_data[:type_parameter])}>"
      end
      # No exception for this type
      return nil
    end

    #
    # Generate a Pascal type signature from a SK function
    # Called by sk_signature_for and lib_signature_for
    #
    def signature_syntax(function, function_name, parameter_list, return_type, opts = {})
      external = "extern " if opts[:is_lib]
      return_type = return_type || "void"
      "internal static #{external}#{return_type} #{function_name}(#{parameter_list})"
    end

    #
    # Convert a list of parameters to a Pascal parameter list
    # Use the type conversion function to get which type to use
    # as this function is used to for both Library and Front-End code
    #
    def parameter_list_syntax(parameters, type_conversion_fn, opts = {})
      parameters.map do |param_name, param_data|
        type = send(type_conversion_fn, param_data)
        if param_data[:is_reference]
          var = param_data[:is_const] ? '' : 'ref '
        end
        "#{var}#{type} #{param_name.variable_case}"
      end.join(', ')
    end

    #
    # Joins the argument list using a comma
    #
    def argument_list_syntax(arguments)
      args = arguments.map do | arg_data |
        if arg_data[:param_data][:is_reference] && ! arg_data[:param_data][:is_const]
          "ref #{arg_data[:name]}"
        else
          arg_data[:name]
        end
      end

      args.join(', ')
    end

    #
    # Defines a Pascal struct field
    #
    def struct_field_syntax(field_name, field_type, _field_data)
      "#{field_name}: #{field_type}"
    end

    #
    # Syntax for declaring array
    #
    def array_declaration_syntax(array_type, dim1_size, dim2_size = nil)
      if dim2_size.nil?
        "Array [0..#{dim1_size - 1}] of #{array_type}"
      else
        "Array [0..#{dim1_size - 1}, 0..#{dim2_size - 1}] of #{array_type}"
      end
    end

    #
    # Syntax for accessing array
    #
    def array_at_index_syntax(idx1, idx2 = nil)
      if idx2.nil?
        "[#{idx1}]"
      else
        "[#{idx1},#{idx2}]"
      end
    end
  end
end
