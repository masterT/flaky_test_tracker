# frozen_string_literal: true

require "octokit"

module FlakyTestTracker
  module Storage
    # GitHub issue test repository.
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

      def self.build(
        client:,
        repository:,
        labels: DEFAULT_LABELS,
        title_template: DEFAULT_TITLE_TEMPLATE,
        body_template: DEFAULT_BODY_TEMPLATE
      )
        new(
          client: Octokit::Client.new(client.merge(auto_paginate: true)),
          repository: repository,
          labels: labels,
          title_rendering: FlakyTestTracker::Rendering.new(template: title_template),
          body_rendering: FlakyTestTracker::Rendering.new(template: body_template),
          serializer: FlakyTestTracker::Serializers::TestHTMLSerializer.new
        )
      end

      attr_reader :client, :repository, :labels, :title_rendering, :body_rendering, :serializer

      # rubocop:disable Metrics/ParameterLists
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
      # rubocop:enable Metrics/ParameterLists

      # @return [Array<Test>]
      def all
        # https://octokit.github.io/octokit.rb/Octokit/Client/Issues.html#list_issues-instance_method
        client
          .list_issues(repository, { state: :open, labels: labels.join(",") })
          .map { |github_issue| to_model(github_issue) }
          .compact
      end

      # @return [Test]
      def find(id)
        # https://octokit.github.io/octokit.rb/Octokit/Client/Issues.html#issue-instance_method
        github_issue = client.issue(repository, id)
        to_model(github_issue)
      end

      # @return [Test]
      def create(test_input)
        test = FlakyTestTracker::Test.new(test_input.serializable_hash)
        # https://octokit.github.io/octokit.rb/Octokit/Client/Issues.html#create_issue-instance_method
        github_issue = client.create_issue(
          repository,
          render_title(test: test),
          render_body(test: test),
          { labels: labels.join(",") }
        )
        to_model(github_issue)
      end

      # @return [Test]
      def update(id, test_input)
        test = FlakyTestTracker::Test.new(test_input.serializable_hash)
        # https://octokit.github.io/octokit.rb/Octokit/Client/Issues.html#update_issue-instance_method
        github_issue = client.update_issue(
          repository,
          id,
          render_title(test: test),
          render_body(test: test),
          { labels: labels }
        )
        to_model(github_issue)
      end

      # @return [Test]
      def delete(id)
        # https://octokit.github.io/octokit.rb/Octokit/Client/Issues.html#close_issue-instance_method
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
