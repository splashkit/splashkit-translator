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
      function[:parameters].reduce("__sklib__#{function[:name]}") do |memo, param|
        param_data = param.last
        ptr = param_data[:is_pointer] ? '_ptr' : ''
        ref = param_data[:is_reference] ? '_ref' : ''
        arr = param_data[:is_array] ? '_array' : ''
        "#{memo}__#{param_data[:type]}#{ref}#{ptr}#{arr}"
      end
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
      return_type     = lib_type_for function[:return]
      parameter_list  = lib_parameter_list_for function
      "#{return_type} #{name}(#{parameter_list})"
    end

    #
    # Convert a list of parameters to a C-library parameter list
    #
    def lib_parameter_list_for(function)
      function[:parameters].reduce('') do |memo, param|
        param_name = param.first
        param_data = param.last
        type = lib_type_for param_data
        "#{memo}, #{type} #{param_name}"
      end[2..-1]
    end

    #
    # Convert a SK type to a C-library type
    #
    def lib_type_for(type_data)
      type = type_data[:type]
      # Handle unsigned [type] as direct
      is_unsigned = type =~ /unsigned/
      return type if is_unsigned
      # Handle void * as __sklib_ptr
      return '__sklib_ptr' if type == 'void' && type_data[:is_pointer]
      {
        'void'      => 'void',
        'int'       => 'int',
        'float'     => 'float',
        'double'    => 'double',
        'byte'      => 'unsigned char', # http://stackoverflow.com/a/87648/519967
        'bool'      => 'int',
        'enum'      => 'int',
        'struct'    => "__sklib_#{type}",
        'string'    => '__sklib_string',
        'typealias' => '__sklib_ptr'
      }[raw_type_for(type)]
    end

    #
    # Returns the size of a N-dimensional array represented as a single
    # dimensional array. E.g., if we have foo[3][3] -> foo[9] (i.e., 3 * 3)
    #
    def get_Nd_array_size_as_1d(field_data)
      field_data[:array_dimension_sizes].inject(:*)
    end

    #
    # Returns the index for
    #
    def get_Nd_array_index_as_1d(field_data, idx)
      is_2d = field_data[:array_dimension_sizes].size == 2
      if is_2d
        r = field_data[:array_dimension_sizes][0]
        c = field_data[:array_dimension_sizes][1] || field_data[:array_dimension_sizes][0]
        '[' + [(idx / r).to_i, idx % c].join('][') + ']'
      else
        "[#{idx}]"
      end
    end

    #
    # Generates a field's struct information
    #
    def make_struct_field(field_name, field_data)
      type = field_data[:type]
      is_pointer = field_data[:is_pointer]
      ptr_star = is_pointer ? '*' : ''
      is_array   = field_data[:is_array]
      # convert n multidimensional array to 1 dimensional array
      size_of_arr = get_Nd_array_size_as_1d(field_data)
      array_decl = is_array ? "[#{size_of_arr}]" : ''
      # actually a __sklib_ptr == void *?
      if is_pointer && type == 'void'
        "__sklib_ptr #{field_name}"
      else
        "__sklib_#{type} #{ptr_star}#{field_name}#{array_decl}"
      end
    end
  end
end
