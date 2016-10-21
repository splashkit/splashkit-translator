require_relative 'abstract_translator'

module Translators
  #
  # SplashKit C Library code generator
  #
  class Pascal < AbstractTranslator
    def initialize(data, logging)
      super(data, logging)
      @direct_types = []
    end

    self.case_converters = {
      types:      :pascal_case,
      functions:  :pascal_case,
      variables:  :camel_case
    }

    def render_templates
      {
        'splashkit.pas' => read_template
      }
    end

    def lib_type_for(type_name)
      {
          'int'       => 'LongInt',
          'short'     => 'ShortInt',
          'long'      => 'Int64',
          'float'     => 'Single',
          'double'    => 'Double',
          'byte'      => 'Char',
          'char'      => 'Char',
          'bool'      => 'LongInt',
          'enum'      => 'LongInt',
          'struct'    => "__sklib_#{type_name}",
          'string'    => '__sklib_string',
          'typealias' => "__sklib_#{type_name}"
      }[raw_type_for(type_name)]
    end

    def pascal_type_for(type)
      raw_t = raw_type_for(type)
      lookup_table = @direct_types.merge(
        'bool'      => 'Boolean',
        'string'    => 'String',
        'enum'      => type,
        'struct'    => type,
        'typealias' => type
      )
      lookup_table[raw_t].type_case
    end
  end
end
