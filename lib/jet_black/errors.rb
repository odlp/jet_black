module JetBlack
  class Error < ::StandardError
  end

  class InvalidPathError < Error
    attr_reader :raw_path, :expanded_path

    def initialize(raw_path, expanded_path)
      @raw_path = raw_path
      @expanded_path = expanded_path

      super <<~MSG
        Please specify a relative path within the temp dir.
        Raw path: '#{raw_path}'
        Expanded path: '#{expanded_path}'
      MSG
    end
  end

  class NonExistentFileError < Error
    attr_reader :raw_path, :expanded_path

    def initialize(raw_path, expanded_path)
      @raw_path = raw_path
      @expanded_path = expanded_path

      super <<~MSG
        Please create the file before trying to append content.
        Raw path: '#{raw_path}'
        Expanded path: '#{expanded_path}'
      MSG
    end
  end
end
