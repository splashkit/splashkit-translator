require_relative 'abstract_translator'
require_relative 'translator_helper'

module Translators
  #
  # SplashKit LANGAUGE Library code generator
  #
  class Dart < AbstractTranslator
    include TranslatorHelper

    def initialize(data, logging = false)
      super(data, logging)
    end

    #
    # List the files to be exported, and their templates 
    #
    def render_templates
      {
        'splashkit.dart' => read_template('splashkit.dart')
      }
    end

    #=== internal ===

    DART_IDENTIFIER_CASES = {
      types:      :camel_case,
      functions:  :camel_case,
      variables:  :camel_case,
      fields:     :camel_case,
      constants:  :camel_case
    }

    #
    # Generate a LANGUAGE type signature from a SK function
    #
    def signature_syntax(function, function_name, parameter_list, return_type, opts = {})
      "fn #{function_name}()"
    end

    #
    # Convert a list of parameters to a LANGUAGE parameter list
    # Use the type conversion function to get which type to use
    # as this function is used to for both Library and Front-End code
    #
    def parameter_list_syntax(parameters, type_conversion_fn, opts = {})
      #TODO: Add this later...
    end
  end
end
