module CoreExtensions
  module Array
    #
    # Pluck a key out of an array of hashes
    #
    def pluck(key)
      map { |h| h[key] }
    end

    #
    # Joins an array and indents it by the number of spaces specified
    #
    def indent(by = 4)
      spaces = ' ' * by
      join("\n#{spaces}").strip
    end
  end
end
Array.prepend CoreExtensions::Array
