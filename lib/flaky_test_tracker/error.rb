# frozen_string_literal: true

module FlakyTestTracker
  module Error
    class Base < StandardError; end

    # Raise when deserialization failed.
    class DeserializeError < Base; end
  end
end
