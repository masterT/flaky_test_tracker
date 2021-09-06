# frozen_string_literal: true

module FlakyTestTracker
  module Reporter
    # Reporter for a collection of reporter.
    # @attr [#tracked_test #tracked_tests #resolved_test #resolved_tests] reporters
    # @see BaseReporter
    class CollectionReporter
      attr_reader :reporters

      # Returns a new instance of {CollectionReporter}.
      def self.build(reporters:)
        new(reporters: reporters)
      end

      def initialize(reporters: [])
        @reporters = reporters
      end

      # @see BaseReporter#tracked_tests
      def tracked_tests(tests:, source:, context:)
        reporters.each do |reporter|
          reporter.tracked_tests(tests: tests, source: source, context: context)
        end
      end

      # @see BaseReporter#resolved_tests
      def resolved_tests(tests:)
        reporters.each do |reporter|
          reporter.resolved_tests(tests: tests)
        end
      end
    end
  end
end
