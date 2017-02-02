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
      return true if self =~ /^(true)$/i
      return false if empty? || self =~ /^(false)$/i
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
    # Returns true if string is an int
    #
    def int?
      to_i.to_s == self
    end

    #
    # Split a string and indent it by the number of spaces specified
    #
    def indent(by = 4)
      strip.split("\n").indent(by)
    end

    #
    # Converts from snake_case to camelCase
    #
    def to_camel_case
      human_case = to_human_words
      human_case[0] = human_case[0].downcase
      human_case.join('')
    end

    #
    # Converts from snake_case to PascalCase
    #
    def to_pascal_case
      to_human_case.tr(' ', '')
    end

    #
    # Converts from snake_case to humanised words
    #
    def to_human_words
      gsub(/_([0-9])([a-zA-Z])/) { |match| "_#{$1}_#{$2}" }.split('_').map(&:capitalize).map do |input|
        input.gsub(/^(Rgb|Hsb|Css|Ip|Tcp|Udp|Uri|Rgba)$/){ |match| "#{match.to_upper_case}" } #Dont do Html or Http
      end
    end

    #
    # Converts from snake_case to Humanised Case
    #
    def to_human_case
      to_human_words.join(' ')
    end

    #
    # Converts from snake_case to snake_case (all lower)
    #
    def to_snake_case
      self.downcase
    end

    #
    # Converts to UPPER_CASE (snake but uppercase)
    #
    def to_upper_case
      self.upcase
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
