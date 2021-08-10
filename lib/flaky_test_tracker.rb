# frozen_string_literal: true

require_relative "flaky_test_tracker/version"
require_relative "flaky_test_tracker/sources/abstract_source"
require_relative "flaky_test_tracker/sources/github_source"
require_relative "flaky_test_tracker/source_factory"

module FlakyTestTracker
  class Error < StandardError; end
  # Your code goes here...
end
