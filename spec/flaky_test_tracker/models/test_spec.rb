# frozen_string_literal: true

RSpec.describe FlakyTestTracker::Models::Test, type: :model do
  subject { build(:test) }

  describe "#==" do
    it "returns true with instance having same attributes" do
      other = described_class.new(subject.serializable_hash)
      expect(subject == other).to eq true
    end
  end
end
