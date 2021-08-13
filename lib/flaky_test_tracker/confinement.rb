# frozen_string_literal: true

module FlakyTestTracker
  # Confine test occurence.
  class Confinement
    attr_reader :storage, :source, :test_occurence_inputs

    def initialize(storage:)
      @storage = storage
      @test_occurence_inputs = []
    end

    def add(attributes)
      @test_occurence_inputs << build_test_occurrence_input(attributes)
    end

    def confine
      @test_occurence_inputs.each do |test_occurence_input|
        store_test_occurence_input(test_occurence_input)
      end
    end

    def clear
      @tests = nil
      @test_occurence_inputs = []
    end

    private

    def build_test_occurrence_input(attributes)
      TestOccurrenceInput.new(
        reference: attributes[:reference],
        description: attributes[:description],
        exception: attributes[:exception],
        file_path: attributes[:file_path],
        line_number: attributes[:line_number],
        finished_at: attributes[:finished_at] || Time.current,
        source_location_url: attributes[:source_location_url] || source.file_source_location_url(
          file_path: attributes[:file_path], line_number: attributes[:line_number]
        )
      )
    end

    def store_test_occurence_input(test_occurence_input)
      test_occurence_input.validate!

      test = test_by_reference[test_occurence_input.reference]
      if test
        storage.add_test_occurence(id: test.id, test_occurence_input: test_occurence_input)
      else
        storage.create(test_occurence_input: test_occurence_input)
      end
    end

    def tests
      @tests ||= storage.all
    end

    def test_by_reference
      @test_by_reference ||= tests.each_with_object({}) do |test, hash|
        hash[test.reference] = test
      end
    end
  end
end
