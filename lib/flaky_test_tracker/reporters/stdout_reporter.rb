# frozen_string_literal: true

module FlakyTestTracker
  module Reporters
    # Base reporter.
    class STDOUTReporter < BaseReporter
      DAY_IN_SECOND = 86_400

      # rubocop:disable Lint/UnusedMethodArgument
      def tracked_tests(tests:, source:, context:)
        $stdout.puts(
          "\n[FlakyTestTracker] #{tests.length} test(s) tracked"
        )
      end
      # rubocop:enable Lint/UnusedMethodArgument

      def resolved_tests(tests:, confinement_duration:)
        days = (confinement_duration / DAY_IN_SECOND).round(2)
        $stdout.puts(
          "\n[FlakyTestTracker] #{tests.length} test(s) resolved after #{days} of confinement"
        )
      end
    end
  end
end
