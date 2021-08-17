# frozen_string_literal: true

require "octokit"

FactoryBot.define do
  factory :github_issue, class: Sawyer::Resource do
    skip_create

    # This is a subset of all the attribute posible for a GitHub Issue.
    # https://docs.github.com/en/rest/reference/issues
    agent { Sawyer::Agent.new("https://api.github.com/") }
    id { 1 }
    html_url { "https://github.com/foo/bar/issue/1" }
    body { "There is an issue." }

    initialize_with do
      new(
        agent,
        attributes.except("agent")
      )
    end
  end
end
