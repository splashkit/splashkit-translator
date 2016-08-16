require_relative 'helper'

module Generators
  #
  # SplashKit C++ generator
  #
  class CPP
    include Helper

    def include_ptr_template
      read_template 'ptr'
    end

    def include_strings_template
      @sklibc.include_strings_template
    end

    def declare_types
      (declare_structs + declare_enums + declare_typedefs).flatten.join("\n")
    end

    def declare_type_converters
      @sklibc.declare_type_converters
    end

    def forward_declare_sk_lib
      # Reimplementation of SKLibC's forward_declare_sk_lib
      @sklibc.forward_declare_sk_lib
    end

    def forward_declare_cpp
      pluck_signature(:functions).join("\n")
    end

    def implement_cpp
      # @data.values.pluck(:functions).flatten
      "hi"
    end

    alias helper_execute execute
    def execute
      {
        'test.cpp' => helper_execute
      }
    end

    alias helper_initialize initialize
    def initialize(data, src)
      @sklibc = Generators::SKLibC.new(data, src)
      helper_initialize(data, src)
    end

    private

    #
    # Declare all typealiases from SK code into C++
    #
    def declare_typedefs
      pluck_signature(:typedefs)
    end

    #
    # Declare all enums from SK code into C++
    #
    def declare_enums
      pluck_signature(:enums)
    end

    #
    # Declare all structs from SK code into C++
    #
    def declare_structs
      pluck_signature(:structs)
    end

    #
    # Plucks the "signature" key from the specified data type
    #
    def pluck_signature(type)
      # We can simply reuse the type signatures here as original code is in
      # C++, but for other languages we must use the `alias_info` attributes
      @data.values.pluck(type).flatten.pluck(:signature)
    end
  end
end
