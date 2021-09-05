# frozen_string_literal: true

module FlakyTestTracker
  module Reporter
    # Base reporter.
    class BaseReporter
      # @param tests [Array<Test>]
      # @param source [#file_source_location_uri, #source_uri]
      # @param context [Hash]
      def tracked_tests(tests:, source:, context:); end

      # @param tests [Array<Test>]
      def resolved_tests(tests:); end
    end
  end
end
