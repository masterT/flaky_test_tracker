# frozen_string_literal: true

require "json"

module FlakyTestTracker
  module Utils
    module Mixins
      # JSON with Date and Time deserializer.
      # @see https://github.com/rails/rails/blob/83217025a171593547d1268651b446d3533e2019/activesupport/lib/active_support/json/decoding.rb
      module JSONWithDateTimeDeserializer
        DATE_REGEX = /\A\d{4}-\d{2}-\d{2}\z/
        DATETIME_REGEX = /\A(?:\d{4}-\d{2}-\d{2}|\d{4}-\d{1,2}-\d{1,2}[T \t]+\d{1,2}:\d{2}:\d{2}(\.[0-9]*)?(([ \t]*)Z|[-+]\d{2}?(:\d{2})?)?)\z/

        # @param [String] json JSON serialized value.
        # @return [Hash, Array, Number, Integer, Float, TrueClass, FalseClass, NilClass] Deserialized value with Date and Time.
        # @raise [JSON::ParserError]
        def from_json_with_date_and_time(json)
          convert_dates_and_times(
            JSON.parse(json.to_s)
          )
        end

        private

        def convert_dates_and_times(data)
          case data
          when nil
            nil
          when DATE_REGEX
            begin
              Date.parse(data)
            rescue ArgumentError
              data
            end
          when DATETIME_REGEX
            begin
              Time.parse(data)
            rescue ArgumentError
              data
            end
          when Array
            data.map! { |item| convert_dates_and_times(item) }
          when Hash
            data.transform_values! { |value| convert_dates_and_times(value) }
          else
            data
          end
        end
      end
    end
  end
end
