# frozen_string_literal: true

require "erb"

module FlakyTestTracker
  module Rendering
    # ERB template rendering.
    class ERBRendering
      attr_reader :erb, :template

      def initialize(template:)
        @template = template
      end

      def output(**locals)
        ERB.new(template).result_with_hash(locals)
      end
    end
  end
end
