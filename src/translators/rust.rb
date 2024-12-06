require_relative 'abstract_translator'
require_relative 'translator_helper'

module Translators
  class Rust < AbstractTranslator
    include TranslatorHelper

    def initialize(data, logging = false)
      super(data, logging)
    end

    def render_templates
      {
        'splashkit.rs' => read_template('splashkit.rs'),
      }
    end

    #=== internal ===

    RUST_IDENTIFIER_CASES = {
      types:      :pascal_case,
      functions:  :snake_case,
      variables:  :snake_case,
      fields:     :snake_case,
      constants:  :upper_case
    }

    DIRECT_TYPES = {
      'int8_t'          => 'i8',
      'int'             => 'i32',
      'short'           => 'i16',
      'int64_t'         => 'i64',
      'float'           => 'f32',
      'double'          => 'f64',
      'byte'            => 'u8',
      'unsigned char'   => 'u8',
      'unsigned int'    => 'u32',
      'unsigned short'  => 'u16'
    }

    SK_TYPES_TO_RUST_TYPES = {
      'bool'      => 'bool',
      'string'    => 'String',
      'void'      => '()',
      'char'      => 'char'
    }

    SK_TYPES_TO_LIB_TYPES = {
      'bool'      => 'i32',
      'string'    => '__sklib_string',
      'void'      => 'c_void',
      'enum'      => 'i32',
      'char'      => 'c_char'
    }

    def type_exceptions(type_data, type_conversion_fn, opts = {})
      return '__sklib_ptr' if void_pointer?(type_data)
      return type_data[:type].type_case if function_pointer?(type_data)

      if vector_type?(type_data)
        return "__sklib_vector_#{type_data[:type_parameter]}" if opts[:is_lib]

        return "Vec<#{send(type_conversion_fn, type_data[:type_parameter])}>"
      end

      nil
    end

    def signature_syntax(function, function_name, parameter_list, return_type, opts = {})
      pub = opts[:is_lib] ? '' : 'pub '
      unsafe = opts[:is_lib] ? 'unsafe ' : ''
      extern = opts[:is_lib] ? 'extern "C" ' : ''
      return_type = return_type.nil? ? '' : " -> #{return_type}"

      "#{pub}#{unsafe}#{extern}fn #{function_name}(#{parameter_list})#{return_type}"
    end

    def sk_function_name_for(function)
      "#{function[:name].function_case}#{function[:attributes][:suffix].nil? ? '' : '_'}#{function[:attributes][:suffix]}"
    end

    def parameter_list_syntax(parameters, type_conversion_fn = :sk_type_for, opts = {})
      type_fn = opts[:is_lib] ? :lib_type_for : type_conversion_fn
      parameters.map do |param_name, param_data|
        parameter_syntax(param_name, param_data, type_fn)
      end.join(', ')
    end

    def parameter_syntax(param_name, param_data, type_conversion_fn = :sk_type_for)
      var = param_name.variable_case
      "#{var == 'fn' ? 'r#fn' : var}: #{send(type_conversion_fn, param_data)}"
    end

    def struct_field_syntax(field_name, field_type, field_data)
      "pub #{field_name}: #{field_type}"
    end

    def array_declaration_syntax(array_type, dim1_size, dim2_size = nil)
      if dim2_size.nil?
        "[#{array_type}; #{dim1_size}]"
      else
        "[[#{array_type}; #{dim2_size}]; #{dim1_size}]"
      end
    end

    def array_at_index_syntax(idx1, idx2 = nil)
      if idx2.nil?
        "[#{idx1}]"
      else
        "[#{idx1}][#{idx2}]"
      end
    end
  end
end
