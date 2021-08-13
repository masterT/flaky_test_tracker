# frozen_string_literal: true

module FlakyTestTracker
  module Rendering
    # Base rendering.
    class BaseRendering
      attr_reader :template, :rendering_template

      def initialize(template:, rendering_template:)
        @template = template
        @rendering_template = rendering_template
      end

      # @return [String]
      def output(**locals)
        rendering_template.output(template: template, locals: locals)
      end
    end
  end
end
