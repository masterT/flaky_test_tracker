# frozen_string_literal: true

require_relative "active_model/serializers/html_comment"
require_relative "flaky_test_tracker/version"
require_relative "flaky_test_tracker/sources/abstract_source"
require_relative "flaky_test_tracker/sources/github_source"
require_relative "flaky_test_tracker/source_factory"
require_relative "flaky_test_tracker/inputs/test_input"
require_relative "flaky_test_tracker/models/test_occurrence"
require_relative "flaky_test_tracker/models/test"
require_relative "flaky_test_tracker/rendering/base_rendering"
require_relative "flaky_test_tracker/storages/abstract_storage"
require_relative "flaky_test_tracker/storages/github_issue_storage"

module FlakyTestTracker
  class Error < StandardError; end
  # Your code goes here...
end
