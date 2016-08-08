module CoreExtensions
  module Array
    #
    # Pluck a key out of an array of hashes
    #
    def pluck(key)
      map { |h| h[key] }
    end
  end
end
Array.prepend CoreExtensions::Array
