# frozen_string_literal: true

module FlakyTestTracker
  module Storages
    # Storage interface.
    # @abstract
    class AbstractStorage
      # Configure the repository.
      def configure(options)
        raise NotImplementedError
      end

      # @return [Array<Test>]
      def all
        raise NotImplementedError
      end

      # @return [Test]
      def find(id:)
        raise NotImplementedError
      end

      # @return [Test]
      def create(reference:, occurrences:)
        raise NotImplementedError
      end

      # @return [Test]
      def update(id:, reference:, occurrences:)
        raise NotImplementedError
      end

      # # @return [Test]
      # def create_test_occurence(id:, test_occurence_input:)
      #   raise NotImplementedError
      # end

      # @return [nil]
      def delete(id:)
        raise NotImplementedError
      end
    end
  end
end
