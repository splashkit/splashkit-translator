require_relative 'helper'

module Generators
  #
  # SplashKit C Library code generator
  #
  class SKLibC
    include Helper

    attr_readers :src, :header_path, :include_directory

    alias helper_execute execute
    def execute
      {
        'sklib.c' => helper_execute,
        'makefile' => read_template('makefile')
      }
    end

    #
    # Renders the types template
    #
    def render_types_template
      @enums = @data.values.pluck(:enums).flatten
      @typealiases = @data.values.pluck(:typedefs).flatten
      @structs = @data.values.pluck(:structs).flatten
      read_template 'types'
    end

    #
    # Renders the function template
    #
    def render_functions_template
      @functions = @data.values.pluck(:functions).flatten
      read_template 'functions'
    end

    #
    # Generate a library type signature from a SK function
    #
    def lib_signature_for(function)
      name            = lib_function_name_for function
      return_type     = lib_type_for function[:return_type]
      parameter_list  = lib_parameter_list_for function
      "#{return_type} #{name}(#{parameter_list})"
    end

    #
    # Convert a list of parameters to a C-library parameter list
    #
    def lib_parameter_list_for(function)
      params = function[:parameters]
      result = []
      params.each do |name, data|
        type = lib_type_for data[:type]
        result << "#{type} #{name}"
      end
      result.join(', ')
    end

    #
    # Convert a SK type to a C-library type
    # TODO: Deprecate for underlying type (add underlying_type to struct|enum)
    #
    def lib_type_for(type)
      default_type = 'ptr' # use when we don't have a mapping
      from_sk_to_c = {
        # SK src type -> C type
        'void'   => 'void',
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
    #    my_function(int p1, float p2) => __sklib_my_function__int__float
    #
    def lib_function_name_for(function)
      name_part = function[:name]
      name = "__sklib__#{name_part}"
      params = function[:parameters]
      unless params.empty?
        types_part = params.values.pluck(:type).join('__')
        name << "__#{types_part}"
      end
      name
    end
  end
end
