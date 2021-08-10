# frozen_string_literal: true

require "active_model"

module FlakyTestTracker
  module Models
    # Test model.
    class Test
      include ActiveModel::Model

      ATTRIBUTES = %w[
        storage_id
        test_id
        occurrences
      ].freeze

      attr_accessor(*ATTRIBUTES)

      def attributes
        ATTRIBUTES.zip([]).to_h
      end
    end
  end
end
