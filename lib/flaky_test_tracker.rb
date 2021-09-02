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
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    def reset
      @configuration = nil
    end

    def tracker
      @tracker ||= FlakyTestTracker::Tracker.new(
        pretend: configuration.pretend,
        storage: configuration.storage,
        context: configuration.context,
        source: configuration.source,
        reporter: configuration.reporter
      )
    end

    def resolver
      @resolver ||= FlakyTestTracker::Resolver.new(
        pretend: configuration.pretend,
        storage: configuration.storage,
        reporter: configuration.reporter
      )
    end
  end
end
