# frozen_string_literal: true

require "active_model"

module FlakyTestTracker
  # Test occurrence input.
  class TestInput
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
      number_occurrences
    ].freeze

    attr_accessor(*ATTRIBUTES)

    validates :reference, presence: true
    validates :description, presence: true
    validates :exception, presence: true
    validates :file_path, presence: true
    validates :line_number, presence: true
    validates :finished_at, presence: true
    validates :source_location_url, presence: true
    validates :number_occurrences, presence: true

    def attributes
      ATTRIBUTES.zip([]).to_h
    end

    def ==(other)
      attributes == other.attributes
    end
  end
end