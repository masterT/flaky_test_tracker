# frozen_string_literal: true

require "uri"

module FlakyTestTracker
  module Sources
    # Resolve file location on a GitHub repository.
    # @attr [String] host GitHub repository host.
    # @attr [String] repository GitHub repository name.
    # @attr [String] commit Git commit SHA1.
    # @attr [String] branch Git branch name.
    class GitHubSource
      DEFAULT_HOST = "github.com"

      # Returns a new instance of GitHubSource.
      def self.build(
        repository:,
        commit:,
        branch:,
        host: DEFAULT_HOST
      )
        new(
          host: host,
          repository: repository,
          commit: commit,
          branch: branch
        )
      end

      attr_reader :host, :repository, :commit, :branch

      def initialize(repository:, commit:, branch:, host:)
        @host = host
        @repository = repository
        @commit = commit
        @branch = branch
      end

      # @return [URI] File location on the GitHub repository.
      def file_source_location_uri(file_path:, line_number:)
        uri = URI("https://#{host}/#{repository}/blob/#{commit}/#{file_path}")
        uri.fragment = "L#{line_number}"
        uri
      end

      # @return [URI] GitHub repository location.
      def source_uri
        URI("https://#{host}/#{repository}/tree/#{commit}")
      end
    end
  end
end
