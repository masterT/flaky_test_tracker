# frozen_string_literal: true

module FlakyTestTracker
  # GitHub source.
  # @see AbstractSource
  class GitHubSource < AbstractSource
    DEFAULT_HOST = "github.com"

    attr_reader :host, :repository, :commit, :branch

    def configure(options)
      @host = options.fetch(:host, DEFAULT_HOST)
      @repository = options.fetch(:repository)
      @commit = options.fetch(:commit)
      @branch = options.fetch(:branch)
    end

    def file_source_location_uri(file_path:, line_number:)
      uri = URI("https://#{host}/#{repository}/blob/#{commit}/#{file_path}")
      uri.fragment = "L#{line_number}"
      uri
    end

    def source_uri
      URI("https://#{host}/#{repository}/tree/#{commit}")
    end
  end
end
