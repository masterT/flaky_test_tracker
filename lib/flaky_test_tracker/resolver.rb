# frozen_string_literal: true

module FlakyTestTracker
  # Test resolver.
  class Resolver
    DAY_IN_SECOND = 86_400
    DEFAULT_DURATION_PERIOD_WITHOUT_FAILURE = 40 * DAY_IN_SECOND

    attr_reader :storage, :reporter, :duration_period_without_failure

    def initialize(
      storage:,
      reporter:,
      duration_period_without_failure: DEFAULT_DURATION_PERIOD_WITHOUT_FAILURE
    )
      @storage = storage
      @reporter = reporter
      @duration_period_without_failure = duration_period_without_failure
    end

    # Resolve tests by removing them from the storage.
    # @yield [test] Select the tests to resolve. Default select test without failure during
    #   {#duration_period_without_failure}.
    # @return [Array<Test>] resolved tests.
    def resolve(&block)
      resolved_tests = select_tests(&block).each { |test| resolve_test(test) }
      reporter.resolved_tests(tests: resolved_tests)
      resolved_tests
    end

    private

    def resolve_test(test)
      resolved_test = storage.delete(test.id)
      reporter.resolved_test(test: resolved_test)
      resolved_test
    end

    def select_tests(&block)
      return tests.select(&block) if block_given?

      tests.select do |test|
        test.finished_at <= Time.now - duration_period_without_failure
      end
    end

    def tests
      @tests ||= @storage.all
    end
  end
end
