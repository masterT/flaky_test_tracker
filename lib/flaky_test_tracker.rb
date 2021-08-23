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

# Flaky test tracker.
module FlakyTestTracker
  def self.tracker(**arguments)
    FlakyTestTracker::Tracker.new(
      storage: storage(**arguments[:storage]),
      context: arguments[:context],
      source: source(**arguments[:source]),
      reporter: reporter(
        reporters: arguments[:reporters],
        verbose: arguments[:verbose]
      )
    )
  end

  # rubocop:disable Metrics/MethodLength
  def self.resolver(**arguments)
    FlakyTestTracker::Resolver.new(
      duration_period_without_failure: arguments.fetch(
        :duration_period_without_failure,
        FlakyTestTracker::Resolver::DEFAULT_DURATION_PERIOD_WITHOUT_FAILURE
      ),
      storage: storage(**arguments[:storage]),
      reporter: reporter(
        reporters: arguments[:reporters],
        verbose: arguments[:verbose]
      )
    )
  end
  # rubocop:enable Metrics/MethodLength

  def self.storage(type:, options:)
    case type
    when :github_issue
      FlakyTestTracker::Storage::GitHubIssueStorage.build(**options)
    else
      raise ArgumentError, "Unkown test repository type #{type.inspect}"
    end
  end

  def self.source(type:, options:)
    case type
    when :github
      FlakyTestTracker::Sources::GitHubSource.build(**options)
    else
      raise ArgumentError, "Unkown source type #{type.inspect}"
    end
  end

  def self.reporter(reporters: [], verbose: false)
    reporters << FlakyTestTracker::Reporters::STDOUTReporter.new if verbose
    FlakyTestTracker::Reporter.new(
      reporters: reporters
    )
  end
end
