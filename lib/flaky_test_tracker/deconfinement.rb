# frozen_string_literal: true

module FlakyTestTracker
  # Deconfine test.
  class Deconfinement
    DAY_IN_SECONDS = 86_400
    DEFAULT_CONFINEMENT_DURATION_IN_DAYS = 40

    attr_reader :storage, :reporter, :confinement_duration_in_days

    def initialize(
      storage:,
      reporter:,
      confinement_duration_in_days: DEFAULT_CONFINEMENT_DURATION_IN_DAYS
    )
      @storage = storage
      @reporter = reporter
      @confinement_duration_in_days = confinement_duration_in_days
    end

    def deconfine
      minimum_last_occurence_finished = Time.current - confinement_duration_in_days * DAY_IN_SECONDS
      test.each do |test|
        next unless test.last_occurrence.finished_at < minimum_last_occurence_finished

        deconfine_test(test)
      end
    end

    private

    def tests
      @tests ||= storage.all
    end

    def deconfine_test(test)
      storage.delete(id: test.id)
      # TODO: Reporter.
    end
  end
end
