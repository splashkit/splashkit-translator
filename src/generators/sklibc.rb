require_relative 'helper'

module Generators
  #
  # SplashKit C Library code generator
  #
  class SKLibC
    include Helper

    def include_strings_template
      read_template 'strings'
    end

    def include_types_template
      read_template 'types'
    end

    def declare_type_converters
      custom_types = @data.values.pluck(:structs).flatten +
                     @data.values.pluck(:enums).flatten +
                     @data.values.pluck(:typedefs).flatten
      custom_types.map { |ty| wrap_sk_custom_type(ty) }
                  .join("\n")
    end

    def forward_declare_sk_lib
      external_decl = 'extern "C"'
      function_prototypes =
        @data.values
             .pluck(:functions)
             .flatten
             .map { |fn| sk_function_to_lib_type_signature fn }
             .join(";\n#{external_decl} ")
      "#{external_decl} #{function_prototypes};"
    end

    def implement_sk_lib
      @data.values
           .pluck(:functions)
           .flatten
           .map { |fn| map_sk_function_to_lib_function fn }
           .join("\n")
    end

    private

    #
    # Create the implementation body of a SK function
    #
    def map_sk_function_to_lib_function(function)
      lib_arg_list   = lib_argument_list_for_sk_function_call(function)
      lib_type_sig   = sk_function_to_lib_type_signature(function)
      sk_func_name   = function[:name]
      sk_func_call   = "#{sk_func_name}(#{lib_arg_list})"
      sk_return_type = function[:return_type]
      lib_body       =
        # determine the body based on the return type
        case sk_return_type
        # void function has no special body; just call the SK code
        when 'void'
          "#{sk_func_call};"
        # other types mean we have an intermediary variable typed as the
        # SK return type which we then convert to its associated lib type
        else
          lib_return_type = sk_type_to_lib_type sk_return_type
          lib_return_variable_name = "#{SK_LIB_PREFIX}__return_value"
          read_template 'non_void_fn_body',
                        sk_return_type: sk_return_type,
                        lib_return_variable_name: lib_return_variable_name,
                        sk_func_call: sk_func_call,
                        lib_return_type: lib_return_type
        end
        .split("\n")
        .join("\n    ") # 4 space indentation for debug readability
      read_template 'fn',
                    signature: lib_type_sig,
                    body: lib_body
    end

    #
    # Defines the argument list of a SK function call
    #
    def lib_argument_list_for_sk_function_call(function)
      params = function[:parameters]
      result = []
      params.each do |argument_name, data|
        type = data[:type]
        # Convert lib type to SK type using __to_#{type}
        result << "__to_#{type}(#{argument_name})"
      end
      result.join(', ')
    end

    #
    # Wraps the custom type in a __sk_type_casting macro
    #
    def wrap_sk_custom_type(type)
      type = type[:name]
      "__sk_type_casting(#{type})"
    end

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
      params.each do |name, data|
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
    SK_LIB_PREFIX = '__sklib'.freeze
  end
end
