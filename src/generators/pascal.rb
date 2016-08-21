require_relative 'abstract_generator'

module Generators
  #
  # SplashKit C Library code generator
  #
  class Pascal < AbstractGenerator
    def initialize(data, src)
      super(data, src)
      @direct_types = {
        'int'     => 'Integer',
        'float'   => 'Single',
        'double'  => 'Double'
      }
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

    #
    # Convert a SK type to a pascal type
    #
    def pascal_type_for(type)
      raw_t = raw_type_for(type)
      lookup_table = @direct_types.merge(
        'bool'   => 'Boolean',
        'string' => 'String',
        'enum'   => type,
        'struct' => type
      )
      lookup_table[raw_t].type_case
    end
  end
end
