# frozen_string_literal: true

FactoryBot.define do
  factory :test_occurrence_input, class: FlakyTestTracker::Inputs::TestOccurrenceInput do
    test_id { "spec/foo_spec.rb[1:1]" }
    description { "it is expected to be validate" }
    exception { "Validation error" }
    file_path { "spec/foo_spec.rb" }
    line_number { 123 }
    finished_at { Time.current }
    source_location_uri do
      URI("https://github.com/foo/bar/blob/0612bcf5b16a1ec368ef4ebb92d6be2f7040260b/spec/foo_spec.rb")
    end
  end
end
