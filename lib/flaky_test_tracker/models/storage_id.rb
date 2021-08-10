# frozen_string_literal: true

require "active_model"

module FlakyTestTracker
  module Models
    # Storage ID model.
    class StorageID
      include ActiveModel::Model

      ATTRIBUTES = %w[
        id
        type
        url
      ].freeze

      attr_accessor(*ATTRIBUTES)

      validates :id, presence: true
      validates :type, presence: true
      validates :url, presence: true

      def attributes
        ATTRIBUTES.zip([]).to_h
      end
    end
  end
end
