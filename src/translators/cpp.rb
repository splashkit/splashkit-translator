require_relative 'abstract_translator'

module Translators
  #
  # C++ Front-End Translator
  #
  class CPP < AbstractTranslator
    def render_templates
      {
        'sklib.h' => read_template('cpp.cpp'),
        'sklib.cpp' => read_template('cpp.h'),
        'CMakeLists.txt' => read_template('CMakeLists.txt')
      }
    end

    #
    # Generate a C++ type signature from a SK function
    #
    def cpp_signature_for(function)
      name            = function[:name]
      return_type     = function[:return]
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
  end
end
