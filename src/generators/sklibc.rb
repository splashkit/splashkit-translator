require_relative 'abstract_generator'

module Generators
  #
  # SplashKit C Library code generator
  #
  class SKLibC < AbstractGenerator
    attr_readers :src, :header_path, :include_directory

    def initialize(data, src)
      super(data, src)
      @direct_types = %w(int float double)
    end

    def render_templates
      {
        'sklib.c' => read_template,
        'makefile' => read_template('makefile')
      }
    end

    #
    # Convert the name of a function to its library represented function
    # name, that is:
    #
    #    my_function(int p1, float p2) => __sklib_my_function__int__float
    #
    def self.lib_function_name_for(function)
      "__sklib__#{function[:unique_name]}"
    end

    private

    #
    # Alias to static method for usage on instance
    #
    def lib_function_name_for(function)
      SKLibC.lib_function_name_for(function)
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
    #
    def lib_type_for(type)
      is_unsigned = type =~ /unsigned/
      return type if is_unsigned
      {
        'void'      => 'void',
        'int'       => 'int',
        'float'     => 'float',
        'double'    => 'double',
        'byte'      => 'int',
        'bool'      => 'int',
        'enum'      => 'int',
        'struct'    => "__sklib_#{type}",
        'string'    => '__sklib_string',
        'typealias' => '__sklib_ptr'
      }[raw_type_for(type)]
    end
  end
end
