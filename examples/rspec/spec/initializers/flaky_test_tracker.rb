# frozen_string_literal: true

require "flaky_test_tracker"
require "octokit"

confinement = FlakyTestTracker::Confinement.new(
  context: nil,
  source: FlakyTestTracker::GitHubSource.new(
    repository: "masterT/flaky-test-tracker",
    commit: "14d5052a1770724d205e4069cf44049cb3140efd",
    branch: "main"
  ),
  reporter: FlakyTestTracker::Reporter.new,
  test_repository: FlakyTestTracker::Repositories::Test::GitHubIssueRepository.new(
    client: Octokit::Client.new(
      auto_paginate: true,
      access_token: ENV["GITHUB_ACCESS_TOKEN"]
    ),
    repository: "masterT/flaky-test-confinement-test",
    labels: ["flaky test"],
    title_rendering: FlakyTestTracker::Rendering::ERBRendering.new(
      template: "Flaky test <%= test.reference %>"
    ),
    body_rendering: FlakyTestTracker::Rendering::ERBRendering.new(
      template: [
        "### Reference",
        "",
        "<%= test.reference %>",
        "",
        "### Description",
        "",
        "<i><%= test.description %></i>",
        "",
        "### Exception",
        "",
        "<pre><%= test.exception %></pre>",
        "",
        "### Failed at",
        "",
        "<%= test.finished_at %>",
        "",
        "### Location",
        "",
        "[<%= test.location %>](<%= test.source_location_url %>)",
        ""
      ].join("\n")
    ),
    test_serializer: FlakyTestTracker::Serializers::TestHTMLSerializer.new
  )
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
        exception: example.exception,
        file_path: example.metadata[:file_path],
        line_number: example.metadata[:line_number]
      )
    end
  end

  config.after(:suite) do
    confinement.confine
  end
end
