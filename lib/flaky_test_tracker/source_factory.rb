# frozen_string_literal: true

module FlakyTestTracker
  # Class to initialize and configure source instance.
  class SourceFactory
    def self.build(type:, options:)
      case type
      when :github
        GitHubSource.new(**options)
      else
        raise ArgumentError, "Unkown source for type #{type}"
      end
    end
  end
end
