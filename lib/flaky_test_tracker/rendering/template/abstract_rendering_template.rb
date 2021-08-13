# frozen_string_literal: true

require "erb"

module FlakyTestTracker
  module Rendering
    module Template
      # Rendering template interface.
      class AbstractRenderingTemplate
        # @return [String]
        def output(template:, locals:)
          raise NotImplementedError
        end
      end
    end
  end
end
