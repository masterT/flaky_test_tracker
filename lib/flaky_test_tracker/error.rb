# frozen_string_literal: true

module FlakyTestTracker
  class Error < StandardError; end

  # Raise when deserialization failed.
  class DeserializeError < Error; end
end
