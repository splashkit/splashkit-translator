def prefix_method(name)
  "#{self.name}_#{name}".to_sym
end

def suffix_constant(name)
  "#{name}_#{self.name}".upcase.to_sym
end

module Translators::TranslatorHelper
  #
  # The types which have no change between LanguageX front-end and C-library
  #
  def direct_types_hash
    hash = self.class.const_get(:DIRECT_TYPES)
    if hash.nil?
      raise "Failed to define DIRECT_TYPES hash for #{name} generator. "\
            'These types are types which do not change between C Library '\
            'and SK front-end (e.g., `int` in C++ -> `Integer` in Pascal for '\
            'both the front-end and C library).'
    end
    hash
  end

  #
  # Alias of above
  #
  def direct_types
    direct_types_hash
  end

  #
  # Hash that defines the C++ type to SK front-end type in LanguageX
  #
  def language_types_hash
    const_key = "SK_TYPES_TO_#{name.upcase}_TYPES".to_sym
    hash = self.class.const_get(const_key)
    if hash.nil?
      raise "Failed to define #{const_key} hash for #{name} generator."\
            'These types are types which should be used for the #{name} SK '\
            'front-end (e.g., `bool` in C++ -> `Boolean` in `Pascal` for use in '\
            'SK front-end) but are different to their representation in C '\
            '(e.g., `bool` in C++ -> `LongInt` in Pascal for use in C code).'
    end
    hash
  end

  #
  # Hash that defines the C++ type to C Library type in LanguageX
  #
  def library_types_hash
    hash = self.class.const_get(:SK_TYPES_TO_LIB_TYPES)
    if hash.nil?
      raise "Failed to define SK_TYPES_TO_LIB_TYPES hash for #{name} "\
            'generator. These types are types which should be used for the C'\
            "library code in #{name} (e.g., `bool` in C++ -> `LongInt` in "\
            'Pascal for use in C code) but are different to their SK '\
            'front-end representation (e.g., `bool` in C++ -> `Boolean` '\
            'in `Pascal` for use in SK front-end).'
    end
    hash
  end

  #
  # Type name to use for when calling SK front end code
  #
  def sk_map_type_for(type_name)
    default_map = {
      'enum'      => type_name.type_case,
      'struct'    => type_name.type_case,
      'typealias' => type_name.type_case
    }
    map = default_map.merge(language_types_hash).merge(direct_types_hash)
    type_name = raw_type_for(type_name)
    map[type_name]
  end

  #
  # This is the prefix added to many lib types. Override in translator to
  # change as needed.
  #
  def sklib_prefix
    "__sklib"
  end

  #
  # Type name to use for when calling C library code
  #
  def lib_map_type_for(type_name)
    default_map = {
      'struct'    => "#{sklib_prefix}_#{type_name}",
      'string'    => "#{sklib_prefix}_string",
      'typealias' => "#{sklib_prefix}_ptr"
    }
    map = default_map.merge(library_types_hash).merge(direct_types_hash)
    type_name = raw_type_for(type_name)
    map[type_name]
  end

  #
  # Converts a C++ type to its LanguageX type for use in SK front end
  #
  def sk_type_for(type_data, opts = {})
    # Wrap if raw string provided
    if type_data.is_a? String
      type_data = { type: type_data }
    end
    # Type mapping function to use
    func = opts[:is_lib] ? :lib_map_type_for : :sk_map_type_for
    # Return possible exceptions user has defined
    exception = type_exceptions(type_data, func, opts)
    return exception if exception
    type = type_data[:type]
    # Map directly otherwise...
    result = send(func, type)
    # Map as array of mapped type if applicable
    if type_data[:is_array] && ! opts[:ignore_array]
      dims = type_data[:array_dimension_sizes]
      # Only 1D arrays in library if lib is true
      dim1_size = opts[:is_lib] ? array_size_as_one_dimensional(type_data) : dims.first
      dim2_size = dims.last if array_is_2d?(type_data) && !opts[:is_lib]
      result = array_declaration_syntax(result, dim1_size, dim2_size)
    end
    raise "The type `#{type}` cannot yet be translated into a compatible "\
          "#{name} type" if result.nil?
    result
  end

  #
  # Converts a C++ type to its LanguageX type for use in lib
  #
  def lib_type_for(type_data, opts = {})
    sk_type_for(type_data, opts.merge({ is_lib: true}) )
  end

  #
  # Exceptions for when translating types
  #
  def type_exceptions(_type_data)
    raise 'Not yet implemented!'
  end

  #
  # Syntax to define a function signature
  #
  def signature_syntax(_function)
    raise '`signature_syntax` is not yet implemented!'
  end

  #
  # Generates a Front-End function name from an SK function
  #
  def lib_function_name_for(function)
    Translators::CLib.lib_function_name_for(function)
  end

  #
  # Function name generated
  #
  def sk_function_name_for(function)
    function[:name].function_case
  end

  #
  # Generates a Front-End parameter list from an SK function
  #
  def sk_parameter_list_for(function, opts = {})
    parameters = function[:parameters]
    type_conversion_fn = "#{opts[:is_lib] ? 'lib' : 'sk'}_type_for".to_sym
    parameter_list_syntax(parameters, type_conversion_fn, opts)
  end

  #
  # Generates a Library parameter list from a SK function
  #
  def lib_parameter_list_for(function)
    sk_parameter_list_for(function, is_lib: true)
  end

  #
  # Generates a Method parameter list from a SK function
  #
  def method_parameter_list_for(function)
    sk_parameter_list_for(function, { is_method: true, self: function[:attributes][:self] })
  end

  #
  # Generates a Front-End return type from an SK function
  #
  def sk_return_type_for(function, opts = {})
    return nil unless is_func?(function)
    return_type = function[:return]
    type_conversion_fn = "#{opts[:is_lib] ? 'lib' : 'sk'}_type_for".to_sym
    send(type_conversion_fn, return_type)
  end

  #
  # Generates a Library return type from a SK function
  #
  def lib_return_type_for(function)
    sk_return_type_for(function, is_lib: true)
  end

  #
  # Generates a Front-End parameter list from an SK function
  #
  def sk_vector_type_for(vector_type, opts = {})
    type_conversion_fn = "#{opts[:is_lib] ? 'lib' : 'sk'}_type_for".to_sym
    send(type_conversion_fn, type: vector_type)
  end

  #
  # Generates a Library parameter list from a SK function
  #
  def lib_vector_type_for(function)
    sk_vector_type_for(function, is_lib: true)
  end

  #
  # Generate a Pascal type signature from a SK function
  #
  def sk_signature_for(function, opts = {})
    # Determine function to call for function name, parameter list, and return type
    function_name_func  = "#{opts[:is_lib] ? 'lib' : 'sk'}_function_name_for".to_sym
    parameter_list_func = "#{opts[:is_lib] ? 'lib' : 'sk'}_parameter_list_for".to_sym
    return_type_func    = "#{opts[:is_lib] ? 'lib' : 'sk'}_return_type_for".to_sym

    # Now call the functions to map the data types
    function_name = send(function_name_func, function)
    parameter_list = send(parameter_list_func, function)
    return_type = send(return_type_func, function)

    # Generate the signature from the mapped types
    signature_syntax(function, function_name, parameter_list, return_type, opts)
  end

  def docs_signatures_for(function)
    [ sk_signature_for(function) ]
  end

  #
  # Generate a lib type signature from a SK function
  #
  def lib_signature_for(function)
    sk_signature_for(function, is_lib: true)
  end

  #
  # Generates a field's struct information
  #
  def struct_field_for(_field_name, _field_data)
    raise '`struct_field_for` is not yet implemented! This function '\
          'should return a struct declaration with the field name and data.'
  end

  #
  # Prepares type name for mapping type_data
  #
  def mapper_fn_suffix(type_data)
    # Rip lib type first
    type = type_data[:type]
    # Remove leading __sklib_ underscores if they exist
    type = type[2..-1] if type =~ /^\_{2}/
    # Replace spaces with underscores for unsigned
    type = type.tr("\s", '_')
    # Handle void pointer as generic __sklib_ptr
    type = 'ptr' if void_pointer?(type_data)
    # Append type parameter if vector
    type = "#{type}_#{type_data[:type_parameter]}" if vector_type?(type_data)
    type
  end

  #
  # Mapper function to convert type_data into LanguageX Front-End type
  #
  def sk_mapper_fn_for(type_data)
    func_suffix = mapper_fn_suffix type_data
    "__skadapter__to_#{func_suffix}"
  end

  #
  # Mapper function to convert type_data into C Library type
  #
  def lib_mapper_fn_for(type_data)
    func_suffix = mapper_fn_suffix type_data
    "__skadapter__to_sklib_#{func_suffix}"
  end

  #
  # Syntax when defining a list of arguments.
  #
  def argument_list_syntax(arguments)
    arguments.map { |arg_data| arg_data[:name] }.join(', ')
  end

  #
  # Argument list when making C library calls
  #
  def lib_argument_list_for(function)
    args = function[:parameters].map do |param_name, param_data|
      {
        name: "__skparam__#{param_name}",
        param_data: param_data
      }
    end

    argument_list_syntax(args)
  end

  def method_argument_list_for(function)
    args = function[:parameters].map do |param_name, param_data|
      if param_name.to_s == function[:attributes][:self]
        {
          name: "this",
          param_data: param_data
        }
      else
        {
          name: param_name.variable_case,
          param_data: param_data
        }
      end
    end

    argument_list_syntax(args)
  end

  #
  # Defines the syntax for defining a struct field
  #
  def struct_field_syntax(_field_name, _field_type, _field_data)
    raise '`struct_field_syntax` not implemented. Use this function to define '\
          'the syntax for declaraing a field given the name, data and '\
          'and type.'
  end

  #
  # Array accessor syntax
  #
  def array_at_index_syntax(idx1, idx2 = nil)
    raise '`array_at_index_syntax` not yet implemented! Use this function for '\
          'defining an array accessor with two parameters, the first index '\
          'and the second index (nil if 1D array).'
  end

  #
  # Array declaration syntax (either 1 or 2D)
  #
  def array_declaration_syntax(array_type, dim1_size, dim2_size = nil)
    raise '`array_declaration_syntax` not yet implemented! Use this function '\
          'defining an array definition of a specific array type with two '\
          'dimensions (the second dimension is nil if 1D array).'
  end

  #
  # Front end struct field definition
  #
  def sk_struct_field_for(field_name, field_data)
    field_name = field_name.field_case
    field_type = sk_type_for(field_data)
    struct_field_syntax(field_name, field_type, field_data)
  end

  #
  # Front end lib struct field, ensures arrays are converted to 1D
  #
  def lib_struct_field_for(field_name, field_data)
    field_name = field_name.field_case
    field_type = lib_type_for(field_data)
    struct_field_syntax(field_name, field_type, field_data)
  end

  #
  # Allows test of a function to see if it is a color function
  #
  def is_color_function(fn)
    (!sk_return_type_for(fn).nil?) && sk_return_type_for(fn).to_snake_case() == "color" && fn[:parameters].length == 0 && fn[:name].start_with?("color")
  end

end
