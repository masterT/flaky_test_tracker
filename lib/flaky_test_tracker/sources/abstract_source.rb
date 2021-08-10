# frozen_string_literal: true

module FlakyTestTracker
  # Source interface.
  # @abstract
  class AbstractSource
    # Configure the source.
    def configure(options)
      raise NotImplementedError
    end

    # @return [URI] URI for a file on the source .
    def file_source_location_uri(file_path:, line_number:)
      raise NotImplementedError
    end

    # @return [URI] on the source.
    def source_uri
      raise NotImplementedError
    end
  end
end
