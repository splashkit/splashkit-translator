require_relative 'helper'

module Generators
  #
  # SplashKit C Library code generator
  #
  class SKLibC
    include Helper

    def define_sk_types
      '2'
    end

    def forward_declare_sk_lib
      external_decl = 'extern "C"'
      function_prototypes =
        @data.values
             .pluck(:functions)
             .flatten
             .map { |fn| sk_function_to_lib_type_signature fn }
             .join(";\n#{external_decl} ")
      "#{external_decl} #{function_prototypes}"
    end

    def implement_sk_lib
      '3'
    end

    private

    #
    # Generate a library type signature from a SK function
    #
    def sk_function_to_lib_type_signature(function)
      name            = sk_function_to_lib_function_name function
      return_type     = sk_type_to_lib_type function[:return_type]
      parameter_list  = sk_parameter_list_to_lib_parameter_list function
      "#{return_type} #{name}(#{parameter_list})"
    end

    #
    # Convert a list of parameters to a C-library parameter list
    #
    def sk_parameter_list_to_lib_parameter_list(function)
      params = function[:parameters]
      result = []
      params.each do | name, data |
        type = sk_type_to_lib_type data[:type]
        result << "#{type} #{name}"
      end
      result.join(', ')
    end

    #
    # Convert a SK type to a C-library type
    #
    def sk_type_to_lib_type(type)
      default_type = 'ptr' # use when we don't have a mapping
      from_sk_to_c = {
        # SK src type -> C type
        'int'    => 'int',
        'float'  => 'float',
        'double' => 'double',
        'bool'   => 'int',
        'struct' => 'struct',
        'string' => '__sklib_string'
      }
      from_sk_to_c[type] || default_type
    end

    #
    # Convert the name of a function to its library represented function
    # name, that is:
    #
    #    my_function(int p1, float p2) => __sk_lib_my_function__int__float
    #
    def sk_function_to_lib_function_name(function)
      name_part = function[:name]
      name = "#{SK_LIB_PREFIX}__#{name_part}"
      params = function[:parameters]
      unless params.empty?
        types_part = params.values.pluck(:type).join('__')
        name << "__#{types_part}"
      end
      name
    end

    #
    # SplashKit library prefix name
    #
    SK_LIB_PREFIX = '__sk_lib'.freeze
  end
end
