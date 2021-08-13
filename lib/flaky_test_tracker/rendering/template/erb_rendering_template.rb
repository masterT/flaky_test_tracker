# frozen_string_literal: true

require "erb"

module FlakyTestTracker
  module Rendering
    module Template
      # Render ERB template with locals binding.
      class ERBRenderingTemplate < AbstractRenderingTemplate
        # @return [String]
        def output(template:, locals:)
          erb = ERB.new(template)
          context = OpenStruct.new(locals)
          erb.result(context.instance_eval { binding })
        end
      end
    end
  end
end
