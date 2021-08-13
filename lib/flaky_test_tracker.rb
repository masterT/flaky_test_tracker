# frozen_string_literal: true

require_relative "active_model/serializers/html_comment"
require_relative "flaky_test_tracker/version"
require_relative "flaky_test_tracker/sources/abstract_source"
require_relative "flaky_test_tracker/sources/github_source"
require_relative "flaky_test_tracker/source_factory"
require_relative "flaky_test_tracker/inputs/test_occurrence_input"
require_relative "flaky_test_tracker/models/storage_id"
require_relative "flaky_test_tracker/models/test_occurrence"
require_relative "flaky_test_tracker/models/test"

module FlakyTestTracker
  class Error < StandardError; end
  # Your code goes here...
end
