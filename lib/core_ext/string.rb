module CoreExtensions
  module String
    #
    # Squashes the string down to its most relevant type, trimming where
    # possible
    #
    def squash
      s = strip
      s.to_i || s.to_f || s.to_b || (s.empty? ? nil : s)
    end

    #
    # Converts to a boolean type if applicable, or nil
    #
    def to_b
      return true if self =~ /^(true|t|yes|y|1)$/i
      return false if empty? || self =~ /^(false|f|no|n|0)$/i
      nil
    end

    #
    # Monkey patch to_f to return nil if self doesn't represent a float
    #
    def to_f
      Float(self)
    rescue ArgumentError
      nil
    end

    #
    # Monkey patch to_i to return nil if self doesn't represent an integer
    #
    def to_i
      Integer(self)
    rescue ArgumentError
      nil
    end

    #
    # Split a string and indent it by the number of spaces specified
    #
    def indent(by = 4)
      split("\n").indent(by)
    end
  end
end
String.prepend CoreExtensions::String
