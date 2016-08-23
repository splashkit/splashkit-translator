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
      return true if self =~ /^(true|t|yes)$/i
      return false if empty? || self =~ /^(false|f|no)$/i
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

    #
    # Converts from snake_case to camelCase
    #
    def to_camel_case
      pascal_case = to_pascal_case
      pascal_case[0, 1].downcase + pascal_case[1..-1]
    end

    #
    # Converts from snake_case to PascalCase
    #
    def to_pascal_case
      to_human_case.tr(' ', '')
    end

    #
    # Converts from snake_case to Humanised Case
    #
    def to_human_case
      split('_').map(&:capitalize).join(' ')
    end

    #
    # Converts from snake_case to snake_case (no change)
    #
    def to_snake_case
      self
    end

    #
    # Converts from snake_case to kebab-case
    #
    def to_kebab_case
      to_human_case.downcase.tr(' ', '-')
    end
  end
end
String.prepend CoreExtensions::String
