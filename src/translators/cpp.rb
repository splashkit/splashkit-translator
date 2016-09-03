require_relative 'abstract_translator'

module Translators
  #
  # C++ Front-End Translator
  #
  class CPP < AbstractTranslator
    def render_templates
      @data.map do |header_key, header_data|
        header_file_name = "#{header_key}.h"
        header_contents  = Header.new(header_data, @src)
                                 .read_template('header/header.h')
        [header_file_name, header_contents]
      end.to_h
    end

    #=== internal ===

    private

    class Header < CPP; end
    class Implementation < CPP; end

    #
    # Generate a C++ type signature from a SK function
    #
    def cpp_signature_for(function)
      name            = function[:name]
      return_type     = function[:return][:type]
      parameter_list  = cpp_parameter_list_for function
      "#{return_type} #{name}(#{parameter_list})"
    end

    #
    # Convert a list of parameters to a C++ parameter list
    #
    def cpp_parameter_list_for(function)
      function[:parameters].reduce('') do |memo, param|
        param_name = param.first
        param_data = param.last
        type = param_data[:type]
        ptr = param_data[:is_pointer]   ? '*' : ''
        ref = param_data[:is_reference] ? '&' : ''
        const = param_data[:is_const] ? 'const ' : ''
        "#{memo}, #{const}#{type} #{ptr}#{ref}#{param_name}"
      end[2..-1]
    end

    #
    # Generates a field's struct information
    #
    def cpp_struct_field_for(field_name, field_data)
      type = field_data[:type]
      ptr = field_data[:is_pointer] ? '*' : ''
      ref = field_data[:is_pointer] ? '&' : ''
      array_decl = field_data[:array_dimension_sizes].reduce('[') do |memo, el|
        "#{memo}][el"
      end << ']'
      "#{type} #{ptr}#{ref}#{field_name}#{array_decl}"
    end
  end
end
