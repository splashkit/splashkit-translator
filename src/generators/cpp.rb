require_relative 'helper'

module Generators
  #
  # SplashKit C++ generator
  #
  class CPP
    include Helper

    def forward_declare_sk_lib
      # Reimplementation of SKLibC's forward_declare_sk_lib
      Generators::SKLibC.new(@data).forward_declare_sk_lib
    end
  end
end
