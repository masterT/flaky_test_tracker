# frozen_string_literal: true

RSpec.describe FlakyTestTracker::Serializers::HTMLCommentSerializer do
  subject { described_class.new }

  let(:value) { "foo" }
  let(:html) do
    Nokogiri::XML::Comment.new(
      Nokogiri::HTML::Document.new,
      Base64.encode64(value)
    ).to_html
  end

  describe "#serialize" do
    it "returns HTML representing the value" do
      expect(subject.serialize(value)).to eq(html)
    end
  end

  describe "#deserialize" do
    it "returns deserialized value from HTML" do
      expect(subject.deserialize(html)).to eq(value)
    end
  end
end
