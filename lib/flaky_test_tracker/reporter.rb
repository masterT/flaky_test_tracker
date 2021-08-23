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

    def resolved_test(test:, confinement_duration:)
      reporters.each do |reporter|
        reporter.resolved_test(test: test, confinement_duration: confinement_duration)
      end
    end

    def resolved_tests(tests:, confinement_duration:)
      reporters.each do |reporter|
        reporter.resolved_tests(tests: tests, confinement_duration: confinement_duration)
      end
    end
  end
end
