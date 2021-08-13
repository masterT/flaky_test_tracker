# frozen_string_literal: true

require "active_model"

module FlakyTestTracker
  module Models
    # TestOccurrence model.
    class TestOccurrence
      include ActiveModel::Model
      include ActiveModel::Serializers::JSON

      ATTRIBUTES = %w[
        reference
        description
        exception
        file_path
        line_number
        finished_at
        source_location_url
      ].freeze

      attr_accessor(*ATTRIBUTES)

      def attributes
        ATTRIBUTES.zip([]).to_h
      end
    end
  end
end
