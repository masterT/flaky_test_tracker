# frozen_string_literal: true

FactoryBot.define do
  factory :storage_id, class: FlakyTestTracker::Models::StorageID do
    skip_create

    id { "0612bcf5b16a1ec368ef4ebb92d6be2f7040260b" }
    type { "github_issue" }
    url { "https://github.com/foo/bar/issues/1" }
  end
end
