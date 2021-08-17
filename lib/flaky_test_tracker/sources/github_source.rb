# frozen_string_literal: true

require "uri"

module FlakyTestTracker
  # GitHub source.
  class GitHubSource
    DEFAULT_HOST = "github.com"

    attr_reader :host, :repository, :commit, :branch

    def initialize(repository:, commit:, branch:, host: DEFAULT_HOST)
      @host = host
      @repository = repository
      @commit = commit
      @branch = branch
    end

    # @return [URI] URI for a file on the source.
    def file_source_location_uri(file_path:, line_number:)
      uri = URI("https://#{host}/#{repository}/blob/#{commit}/#{file_path}")
      uri.fragment = "L#{line_number}"
      uri
    end

    # @return [URI] on the source.
    def source_uri
      URI("https://#{host}/#{repository}/tree/#{commit}")
    end
  end
end
