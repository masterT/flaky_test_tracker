# frozen_string_literal: true

require "time"
require "json"
require_relative "../test"
require_relative "html_comment_serializer"

module FlakyTestTracker
  module Serializers
    # Test HTML serializer.
    class TestHTMLSerializer
      attr_reader :html_serializer

      # @param [#serialize #deserialize] html_serializer
      def initialize(html_serializer: HTMLCommentSerializer.new)
        @html_serializer = html_serializer
      end

      # @param [FlakyTestTracker::Test] test
      # @return [String] The HTML representing the test serialized.
      def serialize(test)
        html_serializer.serialize(
          to_json(test)
        )
      end

      # @param [String] html The HTML representing a FlakyTestTracker::Test.
      # @raise FlakyTestTracker::Error::DeserializeError
      # @return [FlakyTestTracker::Test]
      def deserialize(html)
        from_json(
          html_serializer.deserialize(html)
        )
      rescue ActiveSupport::JSON.parse_error
        raise FlakyTestTracker::Error::DeserializeError
      end

      private

      def to_json(test)
        JSON.generate(
          test
            .serializable_hash(except: :finished_at)
            .merge("finished_at" => time_to_json(test.finished_at))
        )
      end

      def from_json(json)
        FlakyTestTracker::Test.new(
          JSON
            .parse(json)
            .tap do |attributes|
              attributes["finished_at"] = time_from_json(attributes["finished_at"])
            end
        )
      end

      def time_to_json(date_time)
        date_time&.iso8601(9)
      end

      def time_from_json(value)
        Time.parse(value)
      end
    end
  end
end
