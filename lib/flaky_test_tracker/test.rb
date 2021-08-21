# frozen_string_literal: true

require "active_model"

module FlakyTestTracker
  # Test model.
  class Test
    include ActiveModel::Model
    include ActiveModel::Serializers::JSON

    ATTRIBUTES = %w[
      id
      url
      reference
      description
      exception
      file_path
      line_number
      finished_at
      source_location_url
      number_occurrences
    ].freeze

    attr_accessor(*ATTRIBUTES)

    def attributes
      ATTRIBUTES.zip([]).to_h
    end

    def ==(other)
      attributes == other.attributes
    end

    def location
      "#{file_path}:#{line_number}"
    end
  end
end
