# frozen_string_literal: true

require "time"
require "json"
require_relative "../test"
require_relative "html_comment_serializer"

module FlakyTestTracker
  module Serializers
    TIME_ATTRIBUTE_NAMES = %w[
      finished_at
      resolved_at
    ].freeze

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
            .serializable_hash(except: TIME_ATTRIBUTE_NAMES)
            .merge(
              TIME_ATTRIBUTE_NAMES.each_with_object({}) do |name, attributes|
                attributes[name] = time_to_json(test.public_send(name))
              end
            )
        )
      end

      def from_json(json)
        FlakyTestTracker::Test.new(
          JSON
            .parse(json)
            .tap do |attributes|
              TIME_ATTRIBUTE_NAMES.each do |name|
                attributes[name] = time_from_json(attributes[name])
              end
            end
        )
      end

      def time_to_json(date_time)
        date_time&.iso8601(9)
      end

      def time_from_json(value)
        case value
        when nil
          nil
        else
          Time.parse(value)
        end
      end
    end
  end
end
