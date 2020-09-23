require_relative 'abstract_translator'

module Translators
  #
  # C++ Front-End Translator
  #
  class CPP < AbstractTranslator
    def initialize(data, logging = false)
      super(data, logging)
      @clib = ReusableCAdapter.new(data, @logging)
    end

    def render_templates
      result = @data.map do |header_key, header_data|
        header_file_name = "#{header_key}.h"
        header_contents  = Header.new(header_data, header_key.to_s, @data, @logging)
                                 .read_template('interface/module_header.h')
        [header_file_name, header_contents]
      end.to_h
      result.merge(
        'splashkit.h'   => read_template('interface/splashkit_header.h'),
        'splashkit.cpp' => read_template('implementation/implementation.cpp'),
        'adapter_type_mapper.h' => @clib.read_template('type_mapper.h'),
        'adapter_type_mapper.cpp' => @clib.read_template('type_mapper.cpp')
      )
    end

    #
    # Generate a C++ type signature from a SK function
    #
    def sk_signature_for(function)
      name            = function[:name]
      return_type     = sk_type_for function[:return]
      parameter_list  = sk_parameter_list_for function
      "#{return_type} #{name}(#{parameter_list})"
    end

    def is_color_function(fn)
      sk_type_for(fn[:return]) == "color" && fn[:parameters].length == 0 && fn[:name].start_with?("color")
    end

    def docs_signatures_for(function)
      result = [ sk_signature_for(function) ]

      if is_color_function(function)
        result.unshift "#define #{function[:name].to_upper_case}"
      end

      result
    end  

    #=== internal ===

    private

    class Header < CPP
      def initialize(data, header_name, src_data, logging)
        super(data, logging)
        @src_data = src_data
        @header_name = header_name
      end

      #
      # Returns dependent types for this header defined in other headers
      # (i.e., types of fields declared in this header declared in others,
      # parameter types declared in this header declared in others etc.)
      #
      def dependent_headers
        field_types =
          unless @structs.empty?
            @structs.pluck(:fields)
                    .reject(&:empty?)
                    .map(&:values)
                    .flatten
                    .pluck(:type)
                    .uniq
          end || []
        param_types =
          unless @functions.empty?
            @functions.pluck(:parameters)
                      .reject(&:empty?)
                      .map(&:values)
                      .flatten
                      .pluck(:type)
                      .uniq
          end || []
        return_types =
          unless @functions.empty?
            @functions.pluck(:return)
                      .reject(&:empty?)
                      .pluck(:type)
          end || []
        dependent_types = (field_types + param_types + return_types)
        @src_data.select do |header_name, header_data|
          types_defined = header_data[:typedefs].pluck(:name) +
                          header_data[:structs].pluck(:name) +
                          header_data[:enums].pluck(:name)
          # Accepted if this header defines some of the dependent types
          # and not this header
          !(types_defined & dependent_types).empty? &&
            header_name != @header_name
        end.keys
      end
    end

    #
    # Convert a list of parameters to a C++ parameter list
    #
    def sk_parameter_list_for(function)
      function[:parameters].reduce('') do |memo, param|
        param_name = param.first
        param_data = param.last
        type = sk_type_for param_data
        ptr = '*' if param_data[:is_pointer]
        ref = '&' if param_data[:is_reference]
        const = 'const ' if param_data[:is_const]
        "#{memo}, #{const}#{type} #{ptr}#{ref}#{param_name}"
      end[2..-1]
    end

    #
    # Generates a field's struct information
    #
    def sk_struct_field_for(field_name, field_data)
      type = sk_type_for field_data
      ptr = '*' if field_data[:is_pointer]
      ref = '&' if field_data[:is_reference]
      if field_data[:is_array]
        array_dims = field_data[:array_dimension_sizes]
        array_decl =
          if array_dims.length == 1
            "[#{array_dims.first}]"
          else
            "[#{array_dims.first}][#{array_dims.last}]"
          end
      end
      "#{type} #{ptr}#{ref}#{field_name}#{array_decl}"
    end

    #
    # Converts SK type to C++ type
    #
    def sk_type_for(type_data)
      # Only hardcode mapping we need
      return 'unsigned char' if type_data[:type] == 'byte'
      type_parameter = "<#{type_data[:type_parameter]}>" if type_data[:type_parameter]
      "#{type_data[:type]}#{type_parameter}"
    end

    #
    # C Lib type to C++ type adapter
    #
    def sk_mapper_fn_for(function)
      # Just use clib SK adapter -- it's the same thing
      @clib.sk_mapper_fn_for(function)
    end

    #
    # C Lib type to C++ type adapter
    #
    def sk_update_fn_for(function)
      # Just use clib SK adapter -- it's the same thing
      @clib.sk_update_fn_for(function)
    end
  end
end
