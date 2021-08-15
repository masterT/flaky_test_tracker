# frozen_string_literal: true

module FlakyTestTracker
  module Utils
    module Mixins
      # HTML comment serializer mixin.
      module HTMLCommentSerializer
        # @param [String] value The value to serialize.
        # @return [String] The value to serialized as HTML comment.
        # @see FlakyTestTracker::Utils::HTMLCommentSerializer.serialize
        def to_html_comment(value)
          ::HTMLCommentSerializer.serialize(value)
        end

        # @param [String] value HTML comment representing the value serialized.
        # @return [String] The value to deserialized.
        # @see FlakyTestTracker::Utils::HTMLCommentSerializer.deserialize
        def from_html_comment(value)
          ::HTMLCommentSerializer.deserialize(value)
        end
      end
    end
  end
end
