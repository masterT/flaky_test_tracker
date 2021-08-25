# frozen_string_literal: true

require "active_model"

module FlakyTestTracker
  # Test persisted with a Storage.
  # @attr [String] id Storage ID.
  # @attr [String] url Storage URL (optional).
  # @attr [String] reference Test unique reference.
  # @attr [String] description Test description.
  # @attr [String] exception Test exception message.
  # @attr [String] file_path Test source code file path.
  # @attr [Integer] line_number Test source code line number.
  # @attr [Time] finished_at The moment the test last occurrence occured.
  # @attr [String] source_location_url Test source code location URL.
  # @attr [Integer] number_occurrences The number of times a failure was tracked.
  class Test
    include ActiveModel::Model
    include ActiveModel::Serializers::JSON

    ATTRIBUTES = %w[
      id
      url
      reference
      description
      exception
      file_path
      line_number
      finished_at
      source_location_url
      number_occurrences
    ].freeze

    attr_accessor(*ATTRIBUTES)

    def attributes
      ATTRIBUTES.zip([]).to_h
    end

    def ==(other)
      attributes == other.attributes
    end

    def location
      "#{file_path}:#{line_number}"
    end
  end
end
