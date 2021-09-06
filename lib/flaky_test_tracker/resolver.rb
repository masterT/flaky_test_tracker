# frozen_string_literal: true

module FlakyTestTracker
  # Test resolver.
  # @attr [Boolean] pretend Run but do not make any changes on the {#storage}
  # @attr [#all #create #update #delete] storage
  # @attr [#tracked_tests #resolved_tests] reporter
  # @attr [Boolean] verbose
  class Resolver
    attr_reader :pretend, :storage, :reporter, :verbose

    def initialize(pretend:, storage:, reporter:, verbose:)
      @pretend = pretend
      @storage = storage
      @reporter = reporter
      @verbose = verbose
    end

    # Resolve tests by deleting them from the storage.
    # @yield [test] Call block with each {Test} on the {#storage} and resolve those when block returns a truthy value.
    # @return [Array<Test>] resolved tests.
    def resolve(&block)
      resolved_tests = storage.all.select(&block).map { |test| resolve_test(test) }
      reporter.resolved_tests(tests: resolved_tests)
      puts "\n[FlakyTestTracker][Resolver] #{resolved_tests.count} test(s) resolved" if verbose
      resolved_tests
    end

    private

    def resolve_test(test)
      return test if pretend

      storage.delete(test.id)
    end
  end
end
