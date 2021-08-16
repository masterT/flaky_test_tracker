# frozen_string_literal: true

RSpec.describe FlakyTestTracker::Inputs::TestInput, type: :model do
  subject { build(:test_input) }

  context "validations" do
    it { should validate_presence_of(:reference) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:exception) }
    it { should validate_presence_of(:file_path) }
    it { should validate_presence_of(:line_number) }
    it { should validate_presence_of(:finished_at) }
    it { should validate_presence_of(:source_location_url) }
  end

  describe "#==" do
    it "returns true with instance having same attributes" do
      other = described_class.new(subject.serializable_hash)
      expect(subject == other).to eq true
    end
  end
end
