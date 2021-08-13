# frozen_string_literal: true

require "nokogiri"
require "base64"

module FlakyTestTracker
  module Serializers
    # Test serializer in Markdown format.
    # @see AbstractSerializer
    class TestHTMLCommentSerializer < AbstractSerializer
      def serialize(test)
        document = Nokogiri::HTML::Document.new
        json = test.to_json
        # We need to encode in base64 since comment:
        # - can't start with: `>` or `->`
        # - can't include: `--`
        base64 = Base64.encode64(json)
        comment = Nokogiri::XML::Comment.new(document, base64)
        comment.to_html
      end

      def deserialize(html)
        document = Nokogiri::HTML(html)
        comment = document.search(".//comment()").first

        raise ArgumentError "Can't deserialize test" unless comment

        base64 = comment.content
        json = Base64.decode64(base64)
        Test.from_json(json)
      end
    end
  end
end
