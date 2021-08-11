require_relative 'abstract_translator'
require_relative 'translator_helper'

module Translators
  #
  # SplashKit Rust Library code generator
  #
  class Rust < AbstractTranslator
    include TranslatorHelper

    def initialize(data, logging = false)
      super(data, logging)
    end

    #
    # Generate the splashkit module
    #
    def render_templates
      {
        'splashkit.rs' => read_template('splashkit.rs')
      }
    end

    #=== internal ===

    RUST_IDENTIFIER_CASES = {
      types:      :snake_case,
      functions:  :snake_case,
      variables:  :snake_case,
      fields:     :snake_case,
      constants:  :upper_case
    }

    #
    # Direct type map primitive data types between the adapter and library code.
    #
    DIRECT_TYPES = {
      'int8_t'          => 'i8',
      'int'             => 'i32',
      'short'           => 'i16',
      'int64_t'         => 'i64',
      'float'           => 'f32',
      'double'          => 'f64',
      'byte'            => 'u8',
      'unsigned int'    => 'u32',
      'unsigned short'  => 'u16'
    }

    SK_TYPES_TO_LIB_TYPES = {
      'bool'      => 'i32',
      'enum'      => 'i32',
      'char'      => 'u8',
      'unsigned char'   => 'u8',
    }

    SK_TYPES_TO_RUST_TYPES = {
      'bool'      => 'bool',
      'char'      => 'char',
      'unsigned char'   => 'char',
    }

    #
    # Generate a Rust type signature from a SK function
    #
    def signature_syntax(function, function_name, parameter_list, return_type, opts = {})
      "fn #{function_name}(#{parameter_list})"
    end

    #
    # Convert a list of parameters to a Rust parameter list
    # Use the type conversion function to get which type to use
    # as this function is used to for both Library and Front-End code
    #
    def parameter_list_syntax(parameters, type_conversion_fn, opts = {})
      parameters.map do |param_name, param_data|
        type = send(type_conversion_fn, param_data)
        # if param_data[:is_reference]
        #   var = param_data[:is_const] ? 'const ' : 'var '
        # end
        "#{param_name.variable_case}: #{type}"
      end.join('; ')
    end

    #
    # Handle any explicitly mapped data types
    #
    def type_exceptions(type_data, type_conversion_fn, opts = {})
      # No exception for this type
      return nil
    end

  end
end
