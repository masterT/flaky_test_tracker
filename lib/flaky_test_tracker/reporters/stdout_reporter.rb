# frozen_string_literal: true

module FlakyTestTracker
  module Reporters
    # Base reporter.
    class STDOUTReporter < BaseReporter
      DAY_IN_SECOND = 86_400

      def confined_tests(tests:, source:, context:)
        $stdout.puts(
          "\n[FlakyTestTracker] #{tests.length} test(s) confined"
        )
      end

      def deconfined_tests(tests:, confinement_duration:)
        days = (confinement_duration / DAY_IN_SECOND).round(2)
        $stdout.puts(
          "\n[FlakyTestTracker] #{tests.length} test(s) deconfined after #{days} of confinement"
        )
      end
    end
  end
end
