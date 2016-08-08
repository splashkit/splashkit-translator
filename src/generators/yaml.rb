require_relative 'helper'
require 'yaml'
require 'hashie'

module Generators
  #
  # SplashKit C Library code generator
  #
  class YAML
    include Helper

    #
    # Initializes the generator with the data provided
    #
    def initialize(data)
      # Ignore the header keys and marshal_dump the OpenStruct
      @data = data.values.map { |d| Hashie.stringify_keys(d.marshal_dump) }
    end

    #
    # Executes the generator on the template file, returning a string result
    #
    def execute
      puts "Executing #{name} generator..."
      yaml = @data.to_yaml
      puts '-> Done!'
      yaml
    end
  end
end
