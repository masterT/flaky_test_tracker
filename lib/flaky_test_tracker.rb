# frozen_string_literal: true

require_relative "flaky_test_tracker/version"
require_relative "flaky_test_tracker/error"
require_relative "flaky_test_tracker/serializers/html_comment_serializer"
require_relative "flaky_test_tracker/serializers/test_html_serializer"
require_relative "flaky_test_tracker/source/github_source"
require_relative "flaky_test_tracker/test_input"
require_relative "flaky_test_tracker/test"
require_relative "flaky_test_tracker/storage/github_issue_storage"
require_relative "flaky_test_tracker/rendering"
require_relative "flaky_test_tracker/reporter/base_reporter"
require_relative "flaky_test_tracker/reporter/collection_reporter"
require_relative "flaky_test_tracker/tracker"
require_relative "flaky_test_tracker/resolver"
require_relative "flaky_test_tracker/configuration"

# Flaky test tracker.
# @attr [Configuration] configuration
module FlakyTestTracker
  class << self
    attr_writer :configuration

    # @return [Configuration] configuration
    def configuration
      @configuration ||= Configuration.new
    end

    # Configure {FlakyTestTracker#configuration}.
    # @yield [Configuration] Yield with the {FlakyTestTracker#configuration}.
    # @see Configuration
    def configure
      yield(configuration)
    end

    # Reset the {FlakyTestTracker#configuration}, {FlakyTestTracker#tracker} and {FlakyTestTracker#resolver}.
    def reset
      @configuration = nil
      @tracker = nil
      @resolver = nil
    end

    # @return [Tracker] Tracker initialized with {FlakyTestTracker#configuration}.
    def tracker
      @tracker ||= FlakyTestTracker::Tracker.new(
        pretend: configuration.pretend,
        verbose: configuration.verbose,
        storage: configuration.storage,
        context: configuration.context,
        source: configuration.source,
        reporter: configuration.reporter
      )
    end

    # @return [Resolver] Resolver initialized with {FlakyTestTracker#configuration}.
    def resolver
      @resolver ||= FlakyTestTracker::Resolver.new(
        pretend: configuration.pretend,
        verbose: configuration.verbose,
        storage: configuration.storage,
        reporter: configuration.reporter
      )
    end
  end
end
