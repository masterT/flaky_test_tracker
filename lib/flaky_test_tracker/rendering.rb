# frozen_string_literal: true

require "erb"

module FlakyTestTracker
  # ERB template rendering.
  class Rendering
    attr_reader :template

    def initialize(template:)
      @template = template
    end

    # Create a ERB template from {template} and return the result bind with the locales.
    # @param locals The locales that will be bind to the ERB template.
    # @return String
    def output(**locals)
      ERB.new(template).result_with_hash(locals)
    end
  end
end
