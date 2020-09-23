require_relative 'abstract_translator'

module Translators
  #
  # SplashKit C Library code generator
  #
  class CLib < AbstractTranslator
    def initialize(data, logging = false)
      super(data, logging)
      @direct_types = %w(
        int8_t
        int
        short
        int64_t
        float
        double
        char
        unsigned\ int
        unsigned\ short
        unsigned\ char
      )
    end

    def render_templates
      {
        'sk_clib.h' => read_template('sk_clib.h'),
        'sk_clib.cpp' => read_template('sk_clib.cpp'),
        'lib_type_mapper.h' => read_template('type_mapper.h'),
        'lib_type_mapper.cpp' => read_template('type_mapper.cpp'),
      }
    end

    #=== internal ===

    #
    # Convert the name of a function to its library represented function
    # name, that is:
    #
    #    my_function(int p1, float p2) => __sklib_my_function__int__float
    #
    def self.lib_function_name_for(function)
      name = "#{FUNC_PREFIX}__#{function[:name].tr("\s", '_')}"
      function[:parameters].reduce(name) do |memo, param|
        param_data = param.last
        ptr = '_ptr' if param_data[:is_pointer]
        ref = '_ref' if param_data[:is_reference]
        arr = '_array' if param_data[:is_array]
        # Replace spaces with underscores for unsigned
        type = param_data[:type].tr("\s", '_')
        type += "_#{param_data[:type_parameter]}" if param_data[:is_vector]
        "#{memo}__#{type}#{ref}#{ptr}#{arr}"
      end
    end

    def lib_function_name_for(function)
      CLib.lib_function_name_for(function)
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
        # If a C++ reference, we must convert to a C pointer
        ptr = '*' if param_data[:is_pointer] || (param_data[:is_reference] && !param_data[:is_const])
        const = 'const ' if param_data[:is_const]
        "#{memo}, #{const}#{type} #{ptr}#{param_name}"
      end[2..-1]
    end

    #
    # Map the type name to a C-library type
    #
    def lib_map_type_for(type_name)
      {
          'void'      => 'void',
          'int'       => 'int',
          'short'     => 'short',
          'int64_t'   => 'int64_t',
          'float'     => 'float',
          'double'    => 'double',
          'byte'      => 'unsigned char',
          'int8_t'    => 'unsigned char',
          'char'      => 'char',
          'bool'      => 'int',
          'enum'      => 'int',
          'struct'    => "__sklib_#{type_name}",
          'string'    => '__sklib_string',
          'typealias' => "__sklib_#{type_name}"
      }[raw_type_for(type_name)]
    end

    #
    # Convert a SK type to a C-library type
    #
    def lib_type_for(type_data)
      type = type_data[:type]
      # Handle unsigned [type] as direct
      return type if unsigned_type?(type_data)
      # Handle void * as __sklib_ptr
      return '__sklib_ptr' if void_pointer?(type_data)
      # Handle function pointers
      return "__sklib_#{type}" if function_pointer?(type_data)
      # Handle vectors
      return "__sklib_vector_#{type_data[:type_parameter]}" if vector_type?(type_data)
      # Map directly otherwise...
      result = lib_map_type_for(type)
      raise "The type `#{type}` cannot yet be translated into a compatible "\
            'C-type for the SplashKit C Library' if result.nil?
      result
    end

    #
    # Array syntax for either a one or two dimensional array
    #
    def array_at_index_syntax(idx1, idx2 = nil)
      unless idx2.nil?
        '[' + [idx1, idx2].join('][') + ']'
      else
        "[#{idx1}]"
      end
    end

    #
    # Generates a field's struct information
    #
    def lib_struct_field_for(field_name, field_data)
      type = field_data[:type]
      is_pointer = field_data[:is_pointer]
      ptr_star = '*' if is_pointer
      is_array   = field_data[:is_array]
      # convert n multidimensional array to 1 dimensional array
      size_of_arr = array_size_as_one_dimensional(field_data)
      array_decl = "[#{size_of_arr}]" if is_array
      # actually a __sklib_ptr == void *?
      if is_pointer && type == 'void'
        "__sklib_ptr #{field_name}"
      else
        "__sklib_#{type} #{ptr_star}#{field_name}#{array_decl}"
      end
    end

    #
    # Generate a to SK adapter function name for the given type
    #
    def sk_mapper_fn_for(type_data)
      type =
        if void_pointer?(type_data)
          # If void* then it's a sklib_ptr
          'sklib_ptr'
        elsif unsigned_type?(type_data)
          # Remove spaces for unsigned
          type_data[:type].tr("\s", '_')
        elsif type_data[:type] == 'byte'
          # If byte then to unsigned char
          'unsigned_char'
        elsif type_data[:type_parameter]
          # A template
          "#{type_data[:type]}_#{type_data[:type_parameter]}"
        else
          # Use standard type
          type_data[:type]
        end
      "#{func_prefix}__to_#{type}"
    end

    #
    # Generate a function name to update a type
    #
    def sk_update_fn_for(type_data)
      type =
        if type_data[:type_parameter]
          # A template
          "from_#{type_data[:type]}_#{type_data[:type_parameter]}"
        else
          # Use standard type
          raise Parser::Error, 'Attempt to use invalid update function....'
        end
      "#{func_prefix}__update_#{type}"
    end

    #
    # Generate a to library adapter function name for the given type
    #
    def lib_mapper_fn_for(type_data)
      # Rip lib type first
      type = lib_type_for type_data
      # Remove leading __sklib_ underscores if they exist
      type = type[2..-1] if type =~ /^\_{2}/
      # Replace spaces with underscores for unsigned
      type = type.tr("\s", '_')
      "#{func_prefix}__to_#{type}"
    end

    #
    # C library allocates strings and vectors on the heap. It should therefore
    # free any allocated heap memory when it is no longer required.
    #
    def splashkit_library?
      true
    end

    #
    # If it is not the library then it is an adapter.
    #
    def splashkit_adapter?
      !splashkit_library?
    end

    #
    # Parameter list for function pointers
    #
    def function_pointer_param_list(fp)
      fp[:parameters].map do |param_name, param_data|
        "#{lib_type_for param_data} #{param_name}"
      end.join(', ')
    end

    #
    # Prefix to use for all functions
    #
    FUNC_PREFIX = '__sklib'.freeze

    #
    # Accessor on instance to FUNC_PREFIX. This is because the templates only
    # have access to the AbstractTranslator instance -- of which the class
    # AbstractTranslator does not define FUNC_PREFIX.
    #
    def func_prefix
      FUNC_PREFIX
    end
  end

  #
  # Reusable C code for C subset langauge translators (i.e., C++, ObjC)
  #
  class ReusableCAdapter < CLib
    #
    # C++ translator should not free strings or vectors -- this is the
    # responsibility of the C lib code that created it.
    #
    def splashkit_library?
      false
    end

    #
    # Prefix to use for all functions -- to prevent symbol errors this
    # should be different than the one in CLib
    #
    FUNC_PREFIX = '__skadapter'.freeze

    #
    # Redeclare func_prefix as superclass implementation refers back to
    # superclass declaration of FUNC_PREFIX
    #
    def func_prefix
      FUNC_PREFIX
    end

    #
    # Ensure name is the same as the parent class for template lookup
    #
    def name
      'clib'
    end
  end
end
