# frozen_string_literal: true

module FlakyTestTracker
  # Reporter proxy for a collection of reporter.
  class Reporter
    attr_reader :reporters

    def initialize(reporters: [])
      @reporters = reporters
    end

    def confined_test(test:, source:, context:)
      reporters.each do |reporter|
        reporter.confined_test(test: test, source: source, context: context)
      end
    end

    def confined_tests(tests:, source:, context:)
      reporters.each do |reporter|
        reporter.confined_tests(tests: tests, source: source, context: context)
      end
    end
  end
end
