# frozen_string_literal: true

FactoryBot.define do
  factory :test, class: FlakyTestTracker::Models::Test do
    test_id { "spec/foo_spec.rb[1:1]" }
    storage_id { build(:storage_id) }
    occurrences { [] }

    factory :test_with_occurrences do
      transient do
        occurrences_count { 1 }
      end

      occurrences do
        Array.new(occurrences_count) do
          build_list(:test_occurrence, 5, test_id: instance.test_id)
        end
      end
    end
  end
end
