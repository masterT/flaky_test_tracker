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

    def deconfined_test(test:, confinement_duration:)
      reporters.each do |reporter|
        reporter.deconfined_test(test: test, confinement_duration: confinement_duration)
      end
    end

    def deconfined_tests(tests:, confinement_duration:)
      reporters.each do |reporter|
        reporter.deconfined_tests(tests: tests, confinement_duration: confinement_duration)
      end
    end
  end
end