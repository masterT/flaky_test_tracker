# frozen_string_literal: true

require "falky_test_tracker"
require "octokit"

confinement = FlakyTestTracker::Confinement.new(
  test_repository: FlakyTestTracker::Repositories::Test::GitHubIssueRepository.new(
    client: Octokit::Client.new(
      auto_paginate: true,
      access_token: ENV["GITHUB_ACCESS_TOKEN"]
    ),
    repository: ""
  )
)

RSpec.configure do |config|
  config.before(:suite) do
    confinement.clear
  end

  config.after(:suite) do
    confinement.clear
  end
end
