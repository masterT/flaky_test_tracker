# frozen_string_literal: true

module FlakyTestTracker
  module Repositories
    module Test
      # GitHub issue test repository.
      class GitHubIssueRepository
        attr_reader :client, :repository, :labels, :title_rendering, :body_rendering, :test_serializer

        def initialize(
          client:,
          repository:,
          labels:,
          title_rendering:,
          body_rendering:,
          test_serializer:
        )
          @client = client
          @repository = repository
          @labels = labels
          @title_rendering = title_rendering
          @body_rendering = body_rendering
          @test_serializer = test_serializer
        end

        # @return [Array<Test>]
        def all
          # https://octokit.github.io/octokit.rb/Octokit/Client/Issues.html#list_issues-instance_method
          client
            .list_issues(repository, { state: :open, labels: labels })
            .map { |github_issue| to_model(github_issue) }
        end

        # @return [Test]
        def find(id)
          # https://octokit.github.io/octokit.rb/Octokit/Client/Issues.html#issue-instance_method
          github_issue = client.issue(repository, id)
          to_model(github_issue)
        end

        # @return [Test]
        def create(test_input)
          test = FlakyTestTracker::Models::Test.new(test_input.serializable_hash)
          # https://octokit.github.io/octokit.rb/Octokit/Client/Issues.html#create_issue-instance_method
          github_issue = client.create_issue(
            repository,
            render_title(test: test),
            render_body(test: test),
            { labels: labels }
          )
          to_model(github_issue)
        end

        # @return [Test]
        def update(id, test_input)
          test = FlakyTestTracker::Models::Test.new(test_input.serializable_hash)
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
            test_serializer.serialize(test),
            body_rendering.output(test: test)
          ].join("\n")
        end

        def to_model(github_issue)
          test_serializer.deserialize(github_issue.body).tap do |test|
            test.id = github_issue.id
            test.url = github_issue[:html_url]
          end
        end
      end
    end
  end
end
