# frozen_string_literal: true

module FlakyTestTracker
  # Test resolver.
  # @attr [Boolean] pretend Run but do not make any changes on the {#storage}
  # @attr [#all #create #update #delete] storage
  # @attr [ProxyReporter] reporter
  class Resolver
    attr_reader :pretend, :storage, :reporter

    def initialize(pretend:, storage:, reporter:)
      @pretend = pretend
      @storage = storage
      @reporter = reporter
    end

    # Resolve tests by deleting them from the storage.
    # @yield [test] Call block with each {Test} on the {#storage} and resolve those when block returns a truthy value.
    # @return [Array<Test>] resolved tests.
    def resolve(&block)
      resolved_tests = storage.all.select(&block).map { |test| resolve_test(test) }
      reporter.resolved_tests(tests: resolved_tests)
      resolved_tests
    end

    private

    def resolve_test(test)
      return test if pretend

      storage.delete(test.id)
    end
  end
end
