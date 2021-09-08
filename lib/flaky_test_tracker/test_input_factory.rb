# frozen_string_literal: true

require "active_model"

module FlakyTestTracker
  # Create {TestInput} instance from {Test} and attributes.
  # @see Tracker.add
  class TestInputFactory
    # Build {TestInput}.
    # @param [Test] test.
    # @param [#file_source_location_uri #source_uri] source
    # @param [Hash] attributes.
    # @return TestInput
    def build(test:, source:, attributes:)
      FlakyTestTracker::TestInput.new(
        attributes.merge(
          resolved_at: nil,
          number_occurrences: build_test_input_number_occurrences(test: test),
          source_location_url: build_test_input_source_location_url(source: source, attributes: attributes)
        )
      )
    end

    def build_test_input_number_occurrences(test:)
      if test
        test.number_occurrences + 1
      else
        1
      end
    end

    def build_test_input_source_location_url(source:, attributes:)
      source.file_source_location_uri(
        file_path: attributes[:file_path],
        line_number: attributes[:line_number]
      ).to_s
    end
  end
end
