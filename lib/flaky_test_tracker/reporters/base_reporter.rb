# frozen_string_literal: true

module FlakyTestTracker
  module Reporters
    # Base reporter.
    class BaseReporter
      def tracked_test(test:, source:, context:); end

      def tracked_tests(tests:, source:, context:); end

      def resolved_test(test:); end

      def resolved_tests(tests:); end
    end
  end
end
