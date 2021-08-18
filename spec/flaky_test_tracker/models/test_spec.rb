# frozen_string_literal: true

RSpec.describe FlakyTestTracker::Models::Test, type: :model do
  subject { build(:test) }

  describe "#==" do
    it "returns true with instance having same attributes" do
      other = described_class.new(subject.serializable_hash)
      expect(subject == other).to eq true
    end
  end

  describe "#location" do
    it "returns the file path and line number location" do
      expect(subject.location).to eq("#{subject.file_path}:#{subject.line_number}")
    end
  end
end
