# frozen_string_literal: true

require "active_model"

module FlakyTestTracker
  module Models
    # Test model.
    class Test
      include ActiveModel::Model
      include ActiveModel::Serializers::JSON
      include ActiveModel::Serializers::HTMLComment

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
      ].freeze

      attr_accessor(*ATTRIBUTES)

      def attributes
        ATTRIBUTES.zip([]).to_h
      end
    end
  end
end
