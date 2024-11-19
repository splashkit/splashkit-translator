require_relative 'abstract_translator'

module Translators
  #
  # Website docs generator
  #
  class Docs < AbstractTranslator
    def initialize(data, logging = false)
      super(data, logging)
    end

    def render_templates
      data = grouped_data
      {
        'api.json' => JSON.pretty_generate(data)
      }
    end

    def grouped_data
      @data
        .group_by { |_, header| header[:group] }
        .map do |group_key, group_data|
          group_template = {
            brief: '',
            description: '',
            functions: [],
            typedefs: [],
            structs: [],
            enums: [],
            defines: []
          }
          group_data =
            group_data.to_h.values.reduce(group_template) do |memo, header_data|
              header_data.each do |key, value|
                next if value.nil? || !memo.key?(key)
                memo[key] += value unless value.empty?
              end
              memo
            end
          map_signatures(group_data)
          [group_key, group_data]
        end.sort.to_h
    end

    def run_for_each_adapter
      # Must translate in order of adapters (case conversion must be
      # in order as String is prepended)
      Translators.adapters.each do |adpt|
        adpt = adpt.new(@data)
        yield adpt
      end
    end

    def map_signatures(data)
      run_for_each_adapter do |adpt|
        # Map function signatures
        data[:functions].each do |function_data|
          function_data[:signatures] ||= {}
          signature = if adpt.respond_to?(:docs_signatures_for)
                        adpt.docs_signatures_for(function_data)
                      else
                        adpt.sk_signature_for(function_data)
                      end
          function_data[:signatures][adpt.name] = signature
        end
    
        # Enum Signature Mapping
        #
        # Generates and maps enum signatures for each adapter.
        # - Uses `enum_signature_syntax` if available, otherwise provides a fallback message.
        # - Each enum constant includes a name (string), description (default: ''), and value (default: 0).
        # - Signatures are stored in the `:signatures` key of the enum data, associated with the adapter's name.
        # 
        # This set of signatures is used in the api.json file, then subsequently in the SplashKit website
        # for displaying a table of each enum's values and descriptions per language.
        #
        data[:enums].each do |enum_data|
          enum_data[:signatures] ||= {}
          
          # Prepare enum values: name, description, and value
          enum_values = enum_data[:constants].map do |const_name, const_details|
            {
              name: const_name.to_s,  # Ensure the name is a string
              description: const_details[:description] || '',  # Handle missing descriptions
              value: const_details[:number] || 0               # Default value to 0 if none is provided
            }
          end
    
          # Generate the enum signature using the adapter
          if adpt.respond_to?(:enum_signature_syntax)
            enum_signature = adpt.enum_signature_syntax(enum_data[:name], enum_values)
            enum_data[:signatures][adpt.name] = enum_signature
          else
            # Provide a fallback if the adapter does not support enum signature syntax
            enum_data[:signatures][adpt.name] = "Enum mapping not supported for #{adpt.name}"
          end
        end
      end
    end
    
    def post_execute
      puts 'Place `api.json` in the `data` directory of the `splashkit.io` repo'
    end
  end
end
