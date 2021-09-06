# frozen_string_literal: true

require "flaky_test_tracker"

FlakyTestTracker.configure do |config|
  config.storage_type = :github_issue
  config.storage_options = {
    client: {
      access_token: ENV["GITHUB_ACCESS_TOKEN"]
    },
    repository: "masterT/flaky_test_tracker_test",
    labels: ["flaky test"]
  }
  config.source_type = :github
  config.source_options = {
    repository: "masterT/flaky_test_tracker",
    commit: "14d5052a1770724d205e4069cf44049cb3140efd",
    branch: "main"
  }
  config.reporter = []
  config.context = {}
  config.verbose = true
  config.pretend = false
end

RSpec.configure do |config|
  config.before(:suite) do
    FlakyTestTracker.tracker.clear
  end

  config.after do |example|
    if example.exception
      FlakyTestTracker.tracker.add(
        reference: example.id,
        description: example.full_description,
        exception: example.exception.gsub(/\x1b\[[0-9;]*[a-zA-Z]/, ""), # Remove ANSI formatting.
        file_path: example.metadata[:file_path],
        line_number: example.metadata[:line_number]
      )
    end
  end

  config.after(:suite) do
    FlakyTestTracker.tracker.track
  rescue StandardError
    # ...
  end
end
