# frozen_string_literal: true

require "active_model"

module FlakyTestTracker
  module Inputs
    # Test occurrence input.
    class TestOccurrenceInput
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

      validates :test_id, presence: true
      validates :description, presence: true
      validates :exception, presence: true
      validates :file_path, presence: true
      validates :line_number, presence: true
      validates :finished_at, presence: true
      validates :source_location_uri, presence: true

      def attributes
        ATTRIBUTES.zip([]).to_h
      end
    end
  end
end
