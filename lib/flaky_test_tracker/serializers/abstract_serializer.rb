# frozen_string_literal: true

module FlakyTestTracker
  module Serializers
    # Abstract serializer.
    # @abstract
    class AbstractSerializer
      def serialize(value)
        raise NotImplementedError
      end

      def deserialize(value)
        raise NotImplementedError
      end
    end
  end
end
