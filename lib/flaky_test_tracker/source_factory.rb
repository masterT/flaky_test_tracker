# frozen_string_literal: true

module FlakyTestTracker
  # Class to initialize and configure source instance.
  class SourceFactory
    def self.configure(type:, options:)
      source = build(type)
      source.configure(options)
      source
    end

    def self.build(type)
      case type
      when :github
        GitHubSource.new
      else
        raise ArgumentError, "Unkown source for type #{type}"
      end
    end
  end
end
