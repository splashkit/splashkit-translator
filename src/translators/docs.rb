require_relative 'abstract_translator'

module Translators
  #
  # Website docs generator
  #
  class Docs < AbstractTranslator
    def render_templates
      {
        "api.json" => JSON.pretty_generate(data)
      }
    end
  end
end
