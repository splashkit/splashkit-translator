module CoreExtensions
  module Nokogiri
    module XML
      # Monkey patch string for squashing
      require_relative '../string.rb'

      # Text representations become squashed
      module Text
        def text
          super.squash
        end
      end

      # Empty NodeSets should return nil
      module NodeSet
        def text
          empty? ? nil : super.squash
        end
      end
    end
  end
end

Nokogiri::XML::Text.prepend CoreExtensions::Nokogiri::XML::Text
Nokogiri::XML::NodeSet.prepend CoreExtensions::Nokogiri::XML::NodeSet
