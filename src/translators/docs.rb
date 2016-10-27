require_relative 'abstract_translator'

module Translators
  #
  # Website docs generator
  #
  class Docs < AbstractTranslator
    def initialize(data, logging = false)
      super(data, logging)
      @adapters = Translators.adapters.map { |t| t.new(@data) }
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
          group_data = map_signatures(group_data)
          [group_key, group_data]
        end.sort.to_h
    end

    def run_for_each_adapter
      @adapters.map do |adapter|
        output = yield adapter
        [adapter.name, output]
      end.to_h
    end

    def function_signatures(function_data)
      function_data.delete :signature
      function_data[:signatures] = run_for_each_adapter do |adpt|
        adpt.sk_signature_for(function_data)
      end
      function_data
    end

    def map_signatures(data)
      data[:functions].map!(&method(:function_signatures))
      data
    end

    def post_execute
      puts 'Place `api.json` in the `data` directory of the `splashkit.io` repo'
    end
  end
end
