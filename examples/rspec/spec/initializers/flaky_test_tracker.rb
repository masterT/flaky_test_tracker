# frozen_string_literal: true

require "flaky_test_tracker"

confinement = FlakyTestTracker.confinement(
  verbose: true,
  source: {
    type: :github,
    options: {
      repository: "masterT/flaky-test-tracker",
      commit: "14d5052a1770724d205e4069cf44049cb3140efd",
      branch: "main"
    }
  },
  reporters: [],
  test_repository: {
    type: :github_issue,
    options: {
      client: {
        access_token: ENV["GITHUB_ACCESS_TOKEN"]
      },
      repository: "masterT/flaky-test-confinement-test",
      labels: ["flaky test"]
    }
  }
)

RSpec.configure do |config|
  config.before(:suite) do
    confinement.clear
  end

  config.after do |example|
    if example.exception
      confinement.add(
        reference: example.id,
        description: example.full_description,
        exception: example.exception.to_s.gsub(/\x1b\[[0-9;]*[a-zA-Z]/, ""), # Remove ANSI formatting.
        file_path: example.metadata[:file_path],
        line_number: example.metadata[:line_number]
      )
    end
  end

  config.after(:suite) do
    confinement.confine
  end
end
