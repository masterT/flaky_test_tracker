# frozen_string_literal: true

FactoryBot.define do
  factory :test, class: FlakyTestTracker::Models::Test do
    skip_create

    id { "0612bcf5b16a1ec368ef4ebb92d6be2f7040260b" }
    url { "https://github.com/foo/bar/issues/1" }
    reference { "spec/foo_spec.rb[1:1]" }
    occurrences { [] }

    factory :test_with_occurrences do
      transient do
        occurrences_count { 1 }
      end

      occurrences do
        Array.new(occurrences_count) do
          build(:test_occurrence, reference: instance.reference)
        end
      end
    end
  end
end
