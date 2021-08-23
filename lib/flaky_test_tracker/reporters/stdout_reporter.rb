# frozen_string_literal: true

module FlakyTestTracker
  module Reporters
    # Base reporter.
    class STDOUTReporter < BaseReporter
      # rubocop:disable Lint/UnusedMethodArgument
      def tracked_tests(tests:, source:, context:)
        $stdout.puts("\n[FlakyTestTracker] #{tests.length} test(s) tracked")
      end
      # rubocop:enable Lint/UnusedMethodArgument

      def resolved_tests(tests:)
        $stdout.puts("\n[FlakyTestTracker] #{tests.length} test(s) resolved")
      end
    end
  end
end
