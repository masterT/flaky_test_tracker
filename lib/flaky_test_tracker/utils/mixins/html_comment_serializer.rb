# frozen_string_literal: true

require "base64"
require "nokogiri"

module FlakyTestTracker
  module Utils
    module Mixins
      # HTML comment serializer mixin.
      module HTMLCommentSerializer
        # @param [String] value The value to serialize.
        # @return [String] The value to serialized as HTML comment.
        def to_html_comment(value)
          document = Nokogiri::HTML::Document.new
          # We need to base64 encode since comment:
          # - can't start with: `>` or `->`
          # - can't include: `--`
          content = Base64.encode64(value)
          comment = Nokogiri::XML::Comment.new(document, content)
          comment.to_html
        end

        # @param [String] value HTML comment representing the value serialized.
        # @return [String] The value to deserialized.
        def from_html_comment(value)
          document = Nokogiri::HTML(value)
          comment = document.search(".//comment()").first
          Base64.decode64(comment.content)
        end
      end
    end
  end
end