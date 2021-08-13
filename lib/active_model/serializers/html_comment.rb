# frozen_string_literal: true

require "active_model"
require "nokogiri"
require "base64"

module ActiveModel
  module Serializers
    # Active Model HTML comment serializer.
    module HTMLComment
      include ActiveModel::Serialization

      def self.included(base)
        base.class_eval do
          include ActiveModel::Serializers::JSON
        end
      end

      # @return [Nokogiri::XML::Comment]
      def as_html_comment
        document = Nokogiri::HTML::Document.new
        # We need to base64 encode since comment:
        # - can't start with: `>` or `->`
        # - can't include: `--`
        Nokogiri::XML::Comment.new(document, Base64.encode64(to_json))
      end

      # @return [self]
      def from_html_comment(html)
        document = Nokogiri::HTML(html)
        comment = document.search(".//comment()").first
        from_json(Base64.decode64(comment.content))
      end
    end
  end
end
