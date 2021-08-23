# frozen_string_literal: true

module FlakyTestTracker
  # Reporter proxy for a collection of reporter.
  class Reporter
    attr_reader :reporters

    def initialize(reporters: [])
      @reporters = reporters
    end

    def tracked_test(test:, source:, context:)
      reporters.each do |reporter|
        reporter.tracked_test(test: test, source: source, context: context)
      end
    end

    def tracked_tests(tests:, source:, context:)
      reporters.each do |reporter|
        reporter.tracked_tests(tests: tests, source: source, context: context)
      end
    end

    def resolved_test(test:)
      reporters.each do |reporter|
        reporter.resolved_test(test: test)
      end
    end

    def resolved_tests(tests:)
      reporters.each do |reporter|
        reporter.resolved_tests(tests: tests)
      end
    end
  end
end
