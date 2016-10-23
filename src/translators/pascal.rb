require_relative 'abstract_translator'

module Translators
  #
  # SplashKit C Library code generator
  #
  class Pascal < AbstractTranslator
    def initialize(data, logging)
      super(data, logging)
    end

    self.case_converters = {
      types:      :pascal_case,
      functions:  :pascal_case,
      variables:  :camel_case
    }

    def render_templates
      {
        'splashkit.pas' => read_template('splashkit.pas')
      }
    end

    #=== internal ===

    private

    def direct_types
      {
        'int'             => 'Integer',
        'short'           => 'ShortInt',
        'long'            => 'Int64',
        'float'           => 'Single',
        'double'          => 'Double',
        'byte'            => 'Char',
        'char'            => 'Char',
        'unsigned char'   => 'Char',
        'unsigned int'    => 'Cardinal',
        'unsigned short'  => 'Word',
        'unsigned long'   => 'Longword'
      }
    end

    #
    # Maps a SK type name to Pascal type name
    #
    def pascal_map_type_for(type_name)
      map = {
        'bool'      => 'Boolean',
        'string'    => 'String',
        'enum'      => type_name,
        'struct'    => type_name,
        'typealias' => type_name
      }
      direct_types.merge(map)[raw_type_for(type_name)]
    end

    #
    # Maps a SK type name to Pascal type name
    #
    def lib_map_type_for(type_name)
      map = {
        'bool'      => 'LongInt',
        'enum'      => 'LongInt',
        'struct'    => "__sklib_<TYPE>",
        'string'    => '__sklib_string',
        'typealias' => "__sklib_<TYPE>"
      }
      direct_types.merge(map)[raw_type_for(type_name)]
    end

    def pascal_type_exceptions(type_data)
      # Handle char* as PChar
      return 'PChar' if char_pointer?(type_data)
      # Handle void * as Pointer
      return 'Pointer' if void_pointer?(type_data)
      # Handle function pointers
      return "TODO" if function_pointer?(type_data)
      # Handle vectors as Array of <T>
      return "Array of #{type_data[:type_parameter]}" if vector_type?(type_data)
    end

    #
    # Converts a SK type to its Pascal type
    #
    def pascal_type_for(type_data, opts = {})
      type = type_data[:type]
      exception = pascal_type_exceptions(type_data)
      return exception if exception
      # Map directly otherwise...
      result = opts[:is_lib] ? lib_map_type_for(type) : pascal_map_type_for(type)
      raise "The type `#{type}` cannot yet be translated into a compatible "\
            'Pascal type' if result.nil?
      result
    end

    #
    # Converts a SK type to its Pascal type for use in lib
    #
    def lib_type_for(type_data)
      pascal_type_for(type_data, is_lib: true)
    end

    #
    # Generate a Pascal type signature from a SK function
    #
    def pascal_signature_for(function, opts = {})
      declaration = is_proc?(function) ? 'procedure' : 'function'
      name = opts[:is_lib] ? CLib.lib_function_name_for(function) : function[:name].function_case
      param_list = pascal_parameter_list_for(function, opts)
      func_suffix = ": #{pascal_type_for(function[:return])}" if is_func?(function)
      "#{declaration} #{name}(#{param_list})#{func_suffix}"
    end

    #
    # Generate a lib type signature from a SK function
    #
    def lib_signature_for(function)
      pascal_signature_for(function, is_lib: true)
    end

    #
    # Convert a list of parameters to a Pascal parameter list
    #
    def pascal_parameter_list_for(function, opts = {})
      function[:parameters].map do |param_name, param_data|
        type = pascal_type_for(param_data, opts)
        if param_data[:is_reference]
          var = param_data[:is_const] ? 'const ' : 'var '
        end
        type = "^#{type}" if param_data[:is_pointer]
        "#{var}#{param_name.variable_case}: #{type}"
      end.join('; ')
    end

    #
    # Generates a field's struct information
    #
    def pascal_struct_field_for(field_name, field_data)
      type = pascal_type_for field_data
      type = "^#{type}" if field_data[:is_pointer]
      if field_data[:is_array]
        array_dims = field_data[:array_dimension_sizes]
        array_decl =
          if array_dims.length == 1
            "[0..#{array_dims.first}]"
          else
            "[0..#{array_dims.first}, 0..#{array_dims.last}]"
          end
        array_decl = "Array #{array_decl} of #{type}"
      end
      "#{field_name}: #{type}"
    end

    #
    # C Lib type to Pascal type mapper
    #
    def pascal_mapper_fn_for(function)
    end

    def lib_mapper_fn_for(type_data)
      # Rip lib type first
      type = type_data[:type]
      # Remove leading __sklib_ underscores if they exist
      type = type[2..-1] if type =~ /^\_{2}/
      # Replace spaces with underscores for unsigned
      type = type.tr("\s", '_')
      "__skadapter__to_sklib_#{type}"
    end
  end
end
