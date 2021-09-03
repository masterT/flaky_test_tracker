# frozen_string_literal: true

module FlakyTestTracker
  module Reporter
    # rubocop:disable Lint/UnusedMethodArgument

    # STDOUT reporter.
    # @see BaseReporter
    class STDOUTReporter < BaseReporter
      # @see BaseReporter#tracked_tests
      def tracked_tests(tests:, source:, context:)
        $stdout.puts("\n[FlakyTestTracker] #{tests.length} test(s) tracked")
      end

      # @see BaseReporter#resolved_tests
      def resolved_tests(tests:)
        $stdout.puts("\n[FlakyTestTracker] #{tests.length} test(s) resolved")
      end
    end
    # rubocop:enable Lint/UnusedMethodArgument
  end
end
