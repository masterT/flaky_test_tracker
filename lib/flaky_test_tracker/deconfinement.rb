# frozen_string_literal: true

module FlakyTestTracker
  # Test deconfinement.
  class Deconfinement
    DAY_IN_SECOND = 86_400
    DEFAULT_CONFINEMENT_DURATION = 40 * DAY_IN_SECOND

    attr_reader :test_repository, :reporter, :confinement_duration

    def initialize(
      test_repository:,
      reporter:,
      confinement_duration: DEFAULT_CONFINEMENT_DURATION
    )
      @test_repository = test_repository
      @reporter = reporter
      @confinement_duration = confinement_duration
    end

    def deconfine
      deconfined_tests = tests_to_deconfine.map { |test| deconfine_test(test) }
      reporter.deconfined_tests(tests: deconfined_tests, confinement_duration: confinement_duration)
      deconfined_tests
    end

    private

    def deconfine_test(test)
      deconfined_test = test_repository.delete(test.id)
      reporter.deconfined_test(test: deconfined_test, confinement_duration: confinement_duration)
      deconfined_test
    end

    def tests_to_deconfine
      tests.select do |test|
        test.finished_at <= Time.now - confinement_duration
      end
    end

    def tests
      @tests ||= @test_repository.all
    end
  end
end
