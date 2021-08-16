# frozen_string_literal: true

require "time"
require "json"
require_relative "../inputs/test_input"

module FlakyTestTracker
  module Serializers
    # Test input HTML serializer.
    class TestInputHTMLSerializer
      attr_reader :html_serializer

      def initialize(html_serializer: HTMLSerializer.new)
        @html_serializer = html_serializer
      end

      # @param [FlakyTestTracker::Inputs::TestInput] test_input.
      # @return [String] The HTML representing the test_input serialized.
      def serialize(test_input)
        html_serializer.serialize(
          to_json(test_input)
        )
      end

      # @param [String] html The HTML representing a _FlakyTestTracker::Inputs::TestInput_.
      # @return [FlakyTestTracker::Inputs::TestInput]
      def deserialize(html)
        from_json(
          html_serializer.deserialize(html)
        )
      end

      private

      def to_json(test_input)
        JSON.generate(
          test_input
            .serializable_hash(except: :finished_at)
            .merge("finished_at" => time_to_json(test_input.finished_at))
        )
      end

      def from_json(json)
        FlakyTestTracker::Inputs::TestInput.new(
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
