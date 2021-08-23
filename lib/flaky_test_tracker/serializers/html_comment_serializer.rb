# frozen_string_literal: true

require "base64"
require "nokogiri"
require_relative "../error"

module FlakyTestTracker
  module Serializers
    # HTML comment serializer.
    class HTMLCommentSerializer
      # @param [String] value The value to serialize.
      # @return [String] The value to serialized as HTML comment.
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
      # @return [String] The value to deserialized.
      def deserialize(value)
        document = Nokogiri::HTML(value)
        comment = document.search(".//comment()").first
        raise FlakyTestTracker::DeserializeError unless comment

        Base64.strict_decode64(comment.content.strip)
      rescue ArgumentError
        raise FlakyTestTracker::DeserializeError
      end
    end
  end
end
