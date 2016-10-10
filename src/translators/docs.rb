require_relative 'abstract_translator'

module Translators
  #
  # Website docs generator
  #
  class Docs < AbstractTranslator
    def render_templates
      data =
        @data.group_by { |_, header| header[:group] }
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
               [group_key, group_data]
             end.sort.to_h
      {
        'api.json' => JSON.pretty_generate(data)
      }
    end
  end
end
