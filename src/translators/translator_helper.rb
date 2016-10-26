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
      'enum'      => type_name,
      'struct'    => type_name,
      'typealias' => type_name
    }
    map = default_map.merge(language_types_hash).merge(direct_types_hash)
    type_name = raw_type_for(type_name)
    map[type_name]
  end

  #
  # Type name to use for when calling C library code
  #
  def lib_map_type_for(type_name)
    default_map = {
      'struct'    => "__sklib_#{type_name}",
      'string'    => '__sklib_string',
      'typealias' => "__sklib_#{type_name}"
    }
    map = default_map.merge(library_types_hash).merge(direct_types_hash)
    type_name = raw_type_for(type_name)
    map[type_name]
  end

  #
  # Converts a C++ type to its LanguageX type for use in SK front end
  #
  def sk_type_for(type_data, opts = {})
    exception = type_exceptions(type_data)
    return exception if exception
    # Map directly otherwise...
    type = type_data[:type]
    func = opts[:is_lib] ? :lib_map_type_for : :sk_map_type_for
    result = send(func, type)
    raise "The type `#{type}` cannot yet be translated into a compatible "\
          "#{name} type" if result.nil?
    result
  end

  #
  # Converts a C++ type to its LanguageX type for use in lib
  #
  def lib_type_for(type_data)
    sk_type_for(type_data, is_lib: true)
  end

  #
  # Exceptions for when translating types
  #
  def type_exceptions(_type_data)
    raise 'Not yet implemented!'
  end

  def sk_signature_syntax
    raise '`sk_signature_syntax` is not yet implemented!'
  end

  #
  # Generates a Front-End function name from an SK function
  #
  def lib_function_name_for(function)
    Translators::CLib.lib_function_name_for(function)
  end

  def sk_function_name_for(function)
    function[:name].function_case
  end

  #
  # Generates a Front-End parameter list from an SK function
  #
  def sk_parameter_list_for(function, opts = {})
    parameters = function[:parameters]
    type_conversion_fn = "#{opts[:is_lib] ? 'lib' : 'sk'}_type_for".to_sym
    parameter_list_syntax(parameters, type_conversion_fn)
  end

  #
  # Generates a Library parameter list from a SK function
  #
  def lib_parameter_list_for(function)
    sk_parameter_list_for(function, is_lib: true)
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
    signature_syntax(function, function_name, parameter_list, return_type)
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
  def mapper_fn_prepare_type_name(type_data)
    # Rip lib type first
    type = type_data[:type]
    # Remove leading __sklib_ underscores if they exist
    type = type[2..-1] if type =~ /^\_{2}/
    # Replace spaces with underscores for unsigned
    type.tr("\s", '_')
  end

  #
  # Mapper function to convert type_data into LanguageX Front-End type
  #
  def sk_mapper_fn_for(type_data)
    type = mapper_fn_prepare_type_name type_data
    "__skadapter__to_#{type}"
  end

  #
  # Mapper function to convert type_data into C Library type
  #
  def lib_mapper_fn_for(type_data)
    type = mapper_fn_prepare_type_name type_data
    "__skadapter__to_sklib_#{type}"
  end

  #
  # Argument list when making C library calls
  #
  def lib_argument_list_for(_function)
    raise '`lib_argument_list_for` is not yet implemented! This function '\
          'should return the argument list of the function call prepended '\
          'with __skparam__[name] and any dereferencing'
  end
end
