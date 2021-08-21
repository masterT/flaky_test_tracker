# frozen_string_literal: true

require "erb"

module FlakyTestTracker
  # ERB template rendering with Hash.
  class Rendering
    attr_reader :template

    def initialize(template:)
      @template = template
    end

    # @return String
    def output(**locals)
      ERB.new(template).result_with_hash(locals)
    end
  end
end
