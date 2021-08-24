# frozen_string_literal: true

module FlakyTestTracker
  # Test resolver.
  class Resolver
    attr_reader :storage, :reporter

    def initialize(storage:, reporter:)
      @storage = storage
      @reporter = reporter
    end

    # Resolve tests by deleting them from the storage.
    # @yield [test] Select the tests to resolve.
    # @return [Array<Test>] resolved tests.
    def resolve(&block)
      resolved_tests = tests.select(&block).map { |test| resolve_test(test) }
      reporter.resolved_tests(tests: resolved_tests)
      resolved_tests
    end

    private

    def resolve_test(test)
      resolved_test = storage.delete(test.id)
      reporter.resolved_test(test: resolved_test)
      resolved_test
    end

    def tests
      @tests ||= @storage.all
    end
  end
end
