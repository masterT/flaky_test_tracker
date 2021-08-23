# frozen_string_literal: true

module FlakyTestTracker
  # Test resolver.
  class Resolver
    DAY_IN_SECOND = 86_400
    DEFAULT_CONFINEMENT_DURATION = 40 * DAY_IN_SECOND

    attr_reader :storage, :reporter, :confinement_duration

    def initialize(
      storage:,
      reporter:,
      confinement_duration: DEFAULT_CONFINEMENT_DURATION
    )
      @storage = storage
      @reporter = reporter
      @confinement_duration = confinement_duration
    end

    def resolve
      resolved_tests = tests_to_resolve.map { |test| resolve_test(test) }
      reporter.resolved_tests(tests: resolved_tests, confinement_duration: confinement_duration)
      resolved_tests
    end

    private

    def resolve_test(test)
      resolved_test = storage.delete(test.id)
      reporter.resolved_test(test: resolved_test, confinement_duration: confinement_duration)
      resolved_test
    end

    def tests_to_resolve
      tests.select do |test|
        test.finished_at <= Time.now - confinement_duration
      end
    end

    def tests
      @tests ||= @storage.all
    end
  end
end
