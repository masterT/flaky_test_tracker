# frozen_string_literal: true

require "base64"
require "nokogiri"
require_relative "../error"

module FlakyTestTracker
  module Serializers
    # HTML comment serializer.
    #
    # It encodes the value in base64 because an HTML comment content can't:
    # - start with: ">" nor "->";
    # - contain: "--".
    # @see https://developer.mozilla.org/en-US/docs/Web/API/Comment
    class HTMLCommentSerializer
      # @param [String] value the value to serialize.
      # @return [String] the value to serialized as HTML comment.
      def serialize(value)
        document = Nokogiri::HTML::Document.new
        # We need to base64 encode since comment:
        # - can't start with: `>` or `->`
        # - can't include: `--`
        content = Base64.strict_encode64(value)
        comment = Nokogiri::XML::Comment.new(document, content)
        comment.to_html
      end

      # @param [String] value HTML comment representing the value serialized.
      # @raise FlakyTestTracker::Error::DeserializeError
      # @return [String] the value to deserialized.
      def deserialize(value)
        document = Nokogiri::HTML(value)
        comment = document.search(".//comment()").first
        raise FlakyTestTracker::Error::DeserializeError unless comment

        Base64.strict_decode64(comment.content.strip)
      rescue ArgumentError
        raise FlakyTestTracker::Error::DeserializeError
      end
    end
  end
end
