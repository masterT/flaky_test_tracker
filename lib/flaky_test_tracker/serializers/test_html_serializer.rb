# frozen_string_literal: true

require "time"
require "json"
require_relative "../models/test"

module FlakyTestTracker
  module Serializers
    # Test HTML serializer.
    class TestHTMLSerializer
      attr_reader :html_serializer

      def initialize(html_serializer: HTMLSerializer.new)
        @html_serializer = html_serializer
      end

      # @param [FlakyTestTracker::Models::Test] test.
      # @return [String] The HTML representing the test serialized.
      def serialize(test)
        html_serializer.serialize(
          to_json(test)
        )
      end

      # @param [String] html The HTML representing a FlakyTestTracker::Models::Test.
      # @return [FlakyTestTracker::Models::Test]
      def deserialize(html)
        from_json(
          html_serializer.deserialize(html)
        )
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
        FlakyTestTracker::Models::Test.new(
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
