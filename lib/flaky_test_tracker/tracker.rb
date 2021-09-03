# frozen_string_literal: true

module FlakyTestTracker
  # rubocop:disable Metrics/ClassLength, Metrics/ParameterLists

  # Test tracker.
  # @attr [Boolean] pretend Run but do not make any changes on the {#storage}
  # @attr [#all #create #update #delete] storage
  # @attr context
  # @attr [#file_source_location_uri #source_uri] source
  # @attr [ProxyReporter] reporter
  # @attr [Array<Hash>] test_inputs_attributes
  class Tracker
    attr_reader :pretend, :storage, :context, :source, :reporter, :test_inputs_attributes

    def initialize(pretend:, storage:, context:, source:, reporter:)
      @pretend = pretend
      @storage = storage
      @context = context
      @source = source
      @reporter = reporter
      @tests = nil
      @test_inputs_attributes = []
    end

    # Add test attributes to the internal queue.
    # @param [String] reference Test unique reference.
    # @param [String] description Test description.
    # @param [String] exception Test exception message.
    # @param [String] file_path Test source code file path.
    # @param [Integer] line_number Test source code line number.
    # @param [Time] finished_at The moment the test execution finished.
    # @see TestInput.
    def add(
      reference:,
      description:,
      exception:,
      file_path:,
      line_number:,
      finished_at: Time.now
    )
      @test_inputs_attributes << {
        reference: reference,
        description: description,
        exception: exception,
        file_path: file_path,
        line_number: line_number,
        finished_at: finished_at
      }
    end

    # For each test attributes in the internal queue.
    # - build {TestInput}
    #   - resolve {TestInput#source_location_url} with {#source}
    #   - increments {TestInput#number_occurrences} when {Test} with the same reference is found on the {#storage}
    # - persiste the {TestInput} on the storage
    # - report tracked_test with persisted {Test}
    # Then report tracked_tests with all persisted {Test}
    # @return [Array<Test>]
    def track
      tracked_tests = test_inputs.map { |test_input| track_test(test_input) }
      reporter.tracked_tests(source: source, context: context, tests: tracked_tests)
      tracked_tests
    end

    # All persisted {Test} on the {#storage}.
    # @return [Array<Test>]
    def tests
      @tests ||= @storage.all
    end

    # Reset the internal queue.
    def clear
      @tests = nil
      @test_inputs_attributes = []
    end

    private

    def track_test(test_input)
      test_input.validate!
      tracked_test = persiste_test(test_input)
      reporter.tracked_test(source: source, context: context, test: tracked_test)
      tracked_test
    end

    def persiste_test(test_input)
      test = find_test_by_reference(test_input.reference)
      if test
        update_test(test, test_input)
      else
        create_test(test_input)
      end
    end

    def update_test(test, test_input)
      return test if pretend

      storage.update(test.id, test_input)
    end

    def create_test(test_input)
      return FlakyTestTracker::Test.new(test_input.serializable_hash) if pretend

      storage.create(test_input)
    end

    def test_inputs
      test_inputs_attributes.map do |attributes|
        test_input = build_test_input(**attributes)
        test_input
      end
    end

    def build_test_input(reference:, file_path:, line_number:, **attributes)
      FlakyTestTracker::TestInput.new(
        attributes.merge(
          reference: reference,
          file_path: file_path,
          line_number: line_number,
          number_occurrences: build_test_input_number_occurrences(reference: reference),
          source_location_url: build_test_input_source_location_url(file_path: file_path, line_number: line_number)
        )
      )
    end

    def build_test_input_number_occurrences(reference:)
      test = find_test_by_reference(reference)
      if test
        test.number_occurrences + 1
      else
        1
      end
    end

    def build_test_input_source_location_url(file_path:, line_number:)
      source.file_source_location_uri(
        file_path: file_path,
        line_number: line_number
      ).to_s
    end

    def find_test_by_reference(reference)
      test_by_reference[reference]
    end

    def test_by_reference
      @test_by_reference ||= tests.each_with_object({}) do |test, hash|
        hash[test.reference] = test
      end
    end
  end
  # rubocop:enable Metrics/ClassLength, Metrics/ParameterLists
end
