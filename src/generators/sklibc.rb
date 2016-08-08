require_relative 'helper'

module Generators
  #
  # SplashKit C Library code generator
  #
  class SKLibC
    include Helper

    def forward_declare_sk_lib
      '1'
    end

    def define_sk_types
      '2'
    end

    def implement_sk_lib
      '3'
    end
  end
end
