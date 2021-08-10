# frozen_string_literal: true

require "active_model"

module FlakyTestTracker
  module Models
    # TestOccurrence model.
    class TestOccurrence
      include ActiveModel::Model

      ATTRIBUTES = %w[
        test_id
        description
        exception
        file_path
        line_number
        finished_at
        source_location_uri
      ].freeze

      attr_accessor(*ATTRIBUTES)

      def attributes
        ATTRIBUTES.zip([]).to_h
      end
    end
  end
end
