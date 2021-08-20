# frozen_string_literal: true

module FlakyTestTracker
  module Reporters
    # Base reporter.
    class BaseReporter
      def confined_test(test:, source:, context:); end

      def confined_tests(tests:, source:, context:); end

      def deconfined_test(test:, confinement_duration:); end

      def deconfined_tests(tests:, confinement_duration:); end
    end
  end
end
