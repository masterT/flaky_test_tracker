# frozen_string_literal: true

require_relative "flaky_test_tracker/version"
require_relative "flaky_test_tracker/serializers/html_serializer"
require_relative "flaky_test_tracker/serializers/test_html_serializer"
require_relative "flaky_test_tracker/sources/github_source"
require_relative "flaky_test_tracker/inputs/test_input"
require_relative "flaky_test_tracker/models/test"
require_relative "flaky_test_tracker/repositories/test/github_issue_repository"
require_relative "flaky_test_tracker/rendering/erb_rendering"
require_relative "flaky_test_tracker/reporter"
require_relative "flaky_test_tracker/reporters/base_reporter"
require_relative "flaky_test_tracker/reporters/stdout_reporter"
require_relative "flaky_test_tracker/confinement"
require_relative "flaky_test_tracker/deconfinement"

# Flaky test tracker.
module FlakyTestTracker
  class Error < StandardError; end

  def self.confinement(**arguments)
    FlakyTestTracker::Confinement.new(
      test_repository: test_repository(**arguments[:test_repository]),
      context: arguments[:context],
      source: source(**arguments[:source]),
      reporter: reporter(
        reporters: arguments[:reporters],
        verbose: arguments[:verbose]
      )
    )
  end

  def self.deconfinement(**arguments)
    FlakyTestTracker::Deconfinement.new(
      test_repository: test_repository(**arguments[:test_repository]),
      reporter: reporter(
        reporters: arguments[:reporters],
        verbose: arguments[:verbose]
      )
    )
  end

  def self.test_repository(type:, options:)
    case type
    when :github_issue
      FlakyTestTracker::Repositories::Test::GitHubIssueRepository.build(**options)
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
