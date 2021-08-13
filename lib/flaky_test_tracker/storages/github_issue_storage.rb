# frozen_string_literal: true

require "octokit"

module FlakyTestTracker
  module Storages
    # GitHub issue storage.
    # @see AbstractStorage
    class GitHubIssueStorage < AbstractStorage
      attr_reader :client, :repository, :label

      def configure(options)
        @client = Octokit::Client.new({ auto_paginate: true }.merge(options.fetch(:client)))
        @repository = options.fetch(:repository)
        @label = options.fetch(:label)
        @title_rendering = options.fetch(:title_rendering)
        @body_rendering = options.fetch(:body_rendering)
      end

      def all
        fetch_github_issues.map do |github_issue|
          to_model(github_issue)
        end
      end

      def find(id:)
        github_issue = fetch_github_issue(id: id)
        to_model(github_issue)
      end

      # def create(test_occurence_input:)
      #   test = build_test(test_occurence_input: test_occurence_input)
      #   github_issue = create_github_issue(test: test)
      #   test.id = build_id(github_issue: github_issue)
      #   to_model(github_issue)
      # end

      # @return [Test]
      def create(reference:, occurrences:)
        test = Test.new(reference: reference, occurrences: occurrences)
        github_issue = create_github_issue(test: test)
        to_model(github_issue)
      end

      # @return [Test]
      def update(id:, reference:, occurrences:)
        test = find(id: id)
        test.assign_attributes(reference: reference, occurrences: occurrences)
        github_issue = update_github_issue(test: test)
        to_model(github_issue)
      end

      # # @return [Test]
      # def update(id:, test_input:)
      #   raise NotImplementedError
      # end

      # def add_test_occurence(id:, test_occurence_input:)
      #   test = find(id: id)
      #   test.occurrences << build_test_occurrence(test_occurence_input: test_occurence_input)
      #   github_issue = update_github_issue(test: test)
      #   to_model(github_issue)
      # end

      def delete(id:)
        raise NotImplementedError
      end

      private

      def build_test(test_occurence_input:)
        FlakyTestTracker::Models::Test.new(
          reference: test_occurence_input.reference,
          occurrences: [
            build_test_occurrence(test_occurence_input: test_occurence_input)
          ]
        )
      end

      def build_test_occurrence(test_occurence_input:)
        # or `test_occurence_input.serializable_hash`
        FlakyTestTracker::Models::TestOccurrence.new(
          reference: test_occurence_input.reference,
          description: test_occurence_input.description,
          exception: test_occurence_input.exception,
          file_path: test_occurence_input.file_path,
          line_number: test_occurence_input.line_number,
          finished_at: test_occurence_input.finished_at,
          source_location_uri: test_occurence_input.source_location_uri
        )
      end

      def build_id(github_issue:)
        FlakyTestTracker::Models::StorageID.new(
          id: github_issue.id,
          type: type,
          url: github_issue[:html_url]
        )
      end

      # TODO: Add configurable options (Ex: assignee, milestone).
      def create_github_issue(test:)
        # https://octokit.github.io/octokit.rb/Octokit/Client/Issues.html#create_issue-instance_method
        client.Octokit.create_issue(
          repository,
          render_title(test: test),
          render_body(test: test),
          { labels: label }
        )
      end

      # TODO: Add configurable options (Ex: assignee, milestone).
      def update_github_issue(test:)
        # https://octokit.github.io/octokit.rb/Octokit/Client/Issues.html#update_issue-instance_method
        client.Octokit.update_issue(
          repository,
          test.id,
          render_title(test: test),
          render_body(test: test),
          { labels: label }
        )
      end

      def render_title(test:)
        title_rendering.output(test: test)
      end

      def render_body(test:)
        "#{test.as_html_comment.to_html}\n#{body_rendering.output(test: test)}"
      end

      def fetch_github_issues
        # https://octokit.github.io/octokit.rb/Octokit/Client/Issues.html#list_issues-instance_method
        client.list_issues(repository, { state: :open, labels: label })
      end

      def fetch_github_issue(id:)
        # https://octokit.github.io/octokit.rb/Octokit/Client/Issues.html#issue-instance_method
        client.issue(repository, id)
      end

      # This should be a class.
      def to_model(github_issue)
        FlakyTestTracker::Models::Test.new(id: build_id(github_issue: github_issue)).from_html_comment(github_issue[:body])
      end
    end
  end
end
