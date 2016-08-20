require_relative 'abstract_generator'

module Generators
  #
  # SplashKit C Library code generator
  #
  class SKLibC < AbstractGenerator
    attr_readers :src, :header_path, :include_directory

    def initialize(data, src)
      super(data, src)
      @enums = @data.values.pluck(:enums).flatten
      @typealiases = @data.values.pluck(:typedefs).flatten
      @structs = @data.values.pluck(:structs).flatten
      @functions = @data.values.pluck(:functions).flatten
      @no_type_changes = %w(int float double)
    end

    def render_templates
      {
        'sklib.c' => read_template,
        'makefile' => read_template('makefile')
      }
    end

    #
    # Renders the types template
    #
    def render_types_template
      read_template 'types'
    end

    #
    # Renders the function template
    #
    def render_functions_template
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
    # Return true iff function provided is void
    #
    def function_is_void?(function)
      function[:return_type] == 'void'
    end

    #
    # Convert a SK type to a C-library type
    #
    def lib_type_for(type)
      # Lookup type
      type =
        if @typealiases.pluck(:name).include? type
          'typealias'
        elsif @structs.pluck(:name).include? type
          'struct'
        elsif @enums.pluck(:name).include? type
          'enum'
        else
          type
        end
      result = {
        # SK src type -> C type
        'void'      => 'void',
        'int'       => 'int',
        'float'     => 'float',
        'double'    => 'double',
        'bool'      => 'int',
        'enum'      => 'int',
        'struct'    => "__sklib_#{type}",
        'string'    => '__sklib_string',
        'typealias' => '__sklib_ptr'
      }[type]
      result
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
