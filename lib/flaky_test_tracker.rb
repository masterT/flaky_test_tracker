# frozen_string_literal: true

require_relative "flaky_test_tracker/version"
require_relative "flaky_test_tracker/serializers/html_serializer"
require_relative "flaky_test_tracker/serializers/test_html_serializer"
require_relative "flaky_test_tracker/sources/abstract_source"
require_relative "flaky_test_tracker/sources/github_source"
require_relative "flaky_test_tracker/source_factory"
require_relative "flaky_test_tracker/inputs/test_input"
require_relative "flaky_test_tracker/models/test"
require_relative "flaky_test_tracker/repositories/test/github_issue_repository"

module FlakyTestTracker
  class Error < StandardError; end
  # Your code goes here...
end
