# frozen_string_literal: true

RSpec.describe FlakyTestTracker do
  it "has a version number" do
    expect(FlakyTestTracker::VERSION).not_to be nil
  end
end
