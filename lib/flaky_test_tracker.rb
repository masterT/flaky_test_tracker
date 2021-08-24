# frozen_string_literal: true

require_relative "flaky_test_tracker/version"
require_relative "flaky_test_tracker/error"
require_relative "flaky_test_tracker/serializers/html_comment_serializer"
require_relative "flaky_test_tracker/serializers/test_html_serializer"
require_relative "flaky_test_tracker/sources/github_source"
require_relative "flaky_test_tracker/test_input"
require_relative "flaky_test_tracker/test"
require_relative "flaky_test_tracker/storage/github_issue_storage"
require_relative "flaky_test_tracker/rendering"
require_relative "flaky_test_tracker/reporter"
require_relative "flaky_test_tracker/reporters/base_reporter"
require_relative "flaky_test_tracker/reporters/stdout_reporter"
require_relative "flaky_test_tracker/tracker"
require_relative "flaky_test_tracker/resolver"
require_relative "flaky_test_tracker/configuration"

# Flaky test tracker.
module FlakyTestTracker
  class << self
    attr_reader :configuration

    def configure
      @configuration ||= Configuration.new
      yield(configuration)
    end

    def reset
      @configuration = Configuration.new
    end

    def tracker(context: {})
      @tracker ||= FlakyTestTracker::Tracker.new(
        storage: configuration.storage,
        context: context,
        source: configuration.source,
        reporter: configuration.reporters
      )
    end

    def resolver(duration_period_without_failure: nil)
      @resolver ||= FlakyTestTracker::Resolver.new(
        { duration_period_without_failure: duration_period_without_failure,
          storage: configuration.storage,
          reporter: configuration.reporters }.compact
      )
    end
  end
end
