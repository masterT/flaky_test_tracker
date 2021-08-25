# frozen_string_literal: true

require "octokit"

# rubocop:disable Metrics/ParameterLists

module FlakyTestTracker
  module Storage
    # Store {Test} on the GitHub Issue of a GitHub repository.
    # @attr [#issue #create_issue #update_issue #close_issue] client GitHub client.
    # @attr [Array<String>] labels GitHub Issue labels used to store tests.
    # @attr [#output] title_rendering Template rendering used to create GitHub Issue title.
    # @attr [#output] body_rendering Template rendering used to create GitHub Issue body.
    # @attr [#serialize, #deserialize] serializer The serializer used to store the {Test} in the GitHub Issue body.
    class GitHubIssueStorage
      DEFAULT_LABELS = ["flaky test"].freeze
      DEFAULT_TITLE_TEMPLATE = "Flaky test <%= test.reference %>"
      DEFAULT_BODY_TEMPLATE = <<~ERB
        ### Reference
        <%= test.reference %>

        ### Description
        <i><%= test.description %></i>

        ### Exception
        <pre><%= test.exception %></pre>

        ### Failed at
        <%= test.finished_at %>

        ### Number occurrences
        <%= test.number_occurrences %>

        ### Location
        [<%= test.location %>](<%= test.source_location_url %>)
      ERB

      # Returns a new instance of GitHubIssueStorage.
      #
      # @param [Hash] client The options passed to Octokit::Client#new (see https://octokit.github.io/octokit.rb/Octokit/Client.html).
      # @param [String] repository GitHub repository name.
      # @param [Array<String>] labels GitHub Issue labels used to store tests.
      # @param [String] title_template ERB Template used to create and update GitHub Issue title,
      #   the variable _test_ will be bind which represent the {Test} to store.
      # @param [String] body_template ERB Template used to create and update GitHub Issue body,
      #   the variable _test_ will be bind which represent the {Test} to store.
      # @param [#serialize, #deserialize] serializer The serializer used to store the {Test} in the GitHub Issue body.
      #
      # @return [GitHubIssueStorage]
      def self.build(
        client:,
        repository:,
        labels: DEFAULT_LABELS,
        title_template: DEFAULT_TITLE_TEMPLATE,
        body_template: DEFAULT_BODY_TEMPLATE,
        serializer: FlakyTestTracker::Serializers::TestHTMLSerializer.new
      )
        new(
          client: Octokit::Client.new(client.merge(auto_paginate: true)),
          repository: repository,
          labels: labels,
          title_rendering: FlakyTestTracker::Rendering.new(template: title_template),
          body_rendering: FlakyTestTracker::Rendering.new(template: body_template),
          serializer: serializer
        )
      end

      attr_reader :client, :repository, :labels, :title_rendering, :body_rendering, :serializer

      def initialize(
        client:,
        repository:,
        labels:,
        title_rendering:,
        body_rendering:,
        serializer:
      )
        @client = client
        @repository = repository
        @labels = labels
        @title_rendering = title_rendering
        @body_rendering = body_rendering
        @serializer = serializer
      end

      # Returns all the {Test} stored on GitHub Issue with state _open_ and with labels {#labels}.
      # @return [Array<Test>]
      def all
        client
          .list_issues(repository, { state: :open, labels: labels.join(",") })
          .map { |github_issue| to_model(github_issue) }
          .compact
      end

      # Returns the {Test} stored on GitHub Issue having the given _id_.
      # @return [Test]
      def find(id)
        github_issue = client.issue(repository, id)
        to_model(github_issue)
      end

      # Create the {Test} on GitHub Issue.
      # The GitHub issue will have the labels specified by the {#labels}.
      # @param [TestInput] test_input
      # @return [Test]
      def create(test_input)
        test = FlakyTestTracker::Test.new(test_input.serializable_hash)
        github_issue = client.create_issue(
          repository,
          render_title(test: test),
          render_body(test: test),
          { labels: labels.join(",") }
        )
        to_model(github_issue)
      end

      # Update the {Test} on GitHub Issue having the given _id_.
      # The GitHub issue will have the labels specified by the {#labels}.
      # @param [String] id
      # @param [TestInput] test_input
      # @return [Test]
      def update(id, test_input)
        test = FlakyTestTracker::Test.new(test_input.serializable_hash)
        github_issue = client.update_issue(
          repository,
          id,
          render_title(test: test),
          render_body(test: test),
          { labels: labels }
        )
        to_model(github_issue)
      end

      # Delete the {Test} on GitHub Issue having the given _id_.
      # @return [Test]
      def delete(id)
        github_issue = client.close_issue(
          repository,
          id
        )
        to_model(github_issue)
      end

      private

      def render_title(test:)
        title_rendering.output(test: test)
      end

      def render_body(test:)
        [
          serializer.serialize(test),
          body_rendering.output(test: test)
        ].join("\n")
      end

      def to_model(github_issue)
        serializer.deserialize(github_issue.body).tap do |test|
          test.id = github_issue.number.to_s
          test.url = github_issue[:html_url]
        end
      rescue StandardError
        # Handle malformed GitHub issue.
        nil
      end
    end
  end
end
# rubocop:enable Metrics/ParameterLists
