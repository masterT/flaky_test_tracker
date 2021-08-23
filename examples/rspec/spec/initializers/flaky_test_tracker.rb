# frozen_string_literal: true

require "flaky_test_tracker"

tracker = FlakyTestTracker.tracker(
  verbose: true,
  source: {
    type: :github,
    options: {
      repository: "masterT/flaky_test_tracker",
      commit: "14d5052a1770724d205e4069cf44049cb3140efd",
      branch: "main"
    }
  },
  reporters: [],
  storage: {
    type: :github_issue,
    options: {
      client: {
        access_token: ENV["GITHUB_ACCESS_TOKEN"]
      },
      repository: "masterT/flaky_test_tracker_test",
      labels: ["flaky test"]
    }
  }
)

RSpec.configure do |config|
  config.before(:suite) do
    tracker.clear
  end

  config.after do |example|
    if example.exception
      tracker.add(
        reference: example.id,
        description: example.full_description,
        exception: example.exception.to_s.gsub(/\x1b\[[0-9;]*[a-zA-Z]/, ""), # Remove ANSI formatting.
        file_path: example.metadata[:file_path],
        line_number: example.metadata[:line_number]
      )
    end
  end

  config.after(:suite) do
    tracker.track
  end
end
