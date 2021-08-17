# frozen_string_literal: true

require "erb"

module FlakyTestTracker
  module Rendering
    # ERB templat rendering.
    class ERBRendering
      attr_reader :erb

      def initialize(template:)
        @erb = ERB.new(template)
      end

      def output(**locals)
        context = OpenStruct.new(locals)
        erb.result(context.instance_eval { binding })
      end
    end
  end
end
