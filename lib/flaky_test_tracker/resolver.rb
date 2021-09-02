# frozen_string_literal: true

module FlakyTestTracker
  # Test resolver.
  class Resolver
    attr_reader :pretend, :storage, :reporter

    def initialize(pretend:, storage:, reporter:)
      @pretend = pretend
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
      resolved_test = delete_test(test)
      reporter.resolved_test(test: resolved_test)
      resolved_test
    end

    def delete_test(test)
      return test if pretend

      storage.delete(test.id)
    end

    def tests
      @tests ||= @storage.all
    end
  end
end
