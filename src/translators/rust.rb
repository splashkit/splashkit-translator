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
    # Generate a Rust type signature from a SK function
    #
    def signature_syntax(function, function_name, parameter_list, return_type, opts = {})
      "fn #{function_name}()"
    end

    #
    # Convert a list of parameters to a Rust parameter list
    # Use the type conversion function to get which type to use
    # as this function is used to for both Library and Front-End code
    #
    def parameter_list_syntax(parameters, type_conversion_fn, opts = {})
    end
  end
end
