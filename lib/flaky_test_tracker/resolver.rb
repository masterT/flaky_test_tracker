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

    # Resolve tests by updating test "resolved_at" attribute to the current time on the storage.
    # @yield [test] Call block with each {Test} with attribute "resolved_at" equals to nil on the {#storage} and
    #   resolve those when block returns a truthy value.
    # @return [Array<Test>] resolved tests.
    def resolve(&block)
      resolved_tests = select_tests(&block).map { |test| resolve_test(test) }
      reporter.resolved_tests(tests: resolved_tests)
      puts "\n[FlakyTestTracker][Resolver] #{resolved_tests.count} test(s) resolved" if verbose
      resolved_tests
    end

    private

    def select_tests(&block)
      storage.all.select do |test|
        next if test.resolved?

        block.call(test)
      end
    end

    def resolve_test(test)
      return test if pretend

      storage.update(
        test.id,
        build_resolved_test_input(test)
      )
    end

    def build_resolved_test_input(test)
      TestInput.new(
        test.serializable_hash(except: %i[id url]).merge(
          resolved_at: Time.now
        )
      )
    end
  end
end
