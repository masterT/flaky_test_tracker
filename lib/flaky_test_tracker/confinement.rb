# frozen_string_literal: true

module FlakyTestTracker
  # Test confinement.
  class Confinement
    attr_reader :test_repository, :context, :source, :reporters, :test_inputs_attributes

    def initialize(test_repository:, context:, source:, reporters:)
      @test_repository = test_repository
      @context = context
      @source = source
      @reporters = reporters
      @tests = nil
      @test_inputs_attributes = []
    end

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

    def confine
      test_inputs.map do |test_input|
        confine_test(test_input)
      end
    end

    def tests
      @tests ||= @test_repository.all
    end

    def clear
      @tests = nil
      @test_inputs_attributes = []
    end

    private

    def confine_test(test_input)
      test_input.validate!
      test = find_test_by_reference(test_input.reference)
      if test
        test_repository.update(test.id, test_input)
      else
        test_repository.create(test_input)
      end
    end

    def test_inputs
      test_inputs_attributes.map do |attributes|
        test_input = build_test_input(**attributes)
        test_input
      end
    end

    def build_test_input(reference:, file_path:, line_number:, **attributes)
      FlakyTestTracker::Inputs::TestInput.new(
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
      source.source_location_uri(
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
end
