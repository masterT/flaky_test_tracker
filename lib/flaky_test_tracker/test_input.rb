# frozen_string_literal: true

require "active_model"

module FlakyTestTracker
  # Test input attributes.
  # @attr [String] reference Test unique reference.
  # @attr [String] description Test description.
  # @attr [String] exception Test exception message.
  # @attr [String] file_path Test source code file path.
  # @attr [Integer] line_number Test source code line number.
  # @attr [Time] finished_at The moment the test execution finished.
  # @attr [Time] resolved_at The moment the test was resolved.
  # @attr [String] source_location_url Test source code location URL.
  # @attr [Integer] number_occurrences The number of times a failure was tracked.
  # @see FlakyTestTracker::Tracker#add
  class TestInput
    include ActiveModel::Model
    include ActiveModel::Serializers::JSON

    # @private
    ATTRIBUTES = %w[
      reference
      description
      exception
      file_path
      line_number
      finished_at
      resolved_at
      source_location_url
      number_occurrences
    ].freeze

    attr_accessor(*ATTRIBUTES)

    validates :reference, presence: true
    validates :description, presence: true
    validates :exception, presence: true
    validates :file_path, presence: true
    validates :line_number, presence: true
    validates :finished_at, presence: true
    validates :source_location_url, presence: true
    validates :number_occurrences, presence: true

    # @private
    def attributes
      ATTRIBUTES.zip([]).to_h
    end

    def ==(other)
      attributes == other.attributes
    end
  end
end
