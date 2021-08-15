# frozen_string_literal: true

RSpec.describe FlakyTestTracker::Utils::HTMLCommentSerializer do
  let(:value) { "foo" }
  let(:html) do
    Nokogiri::XML::Comment.new(
      Nokogiri::HTML::Document.new,
      Base64.encode64(value)
    ).to_html
  end

  describe "::serialize" do
    it "returns HTML comment representing the value" do
      expect(described_class.serialize(value)).to eq(html)
    end
  end

  describe "::deserialize" do
    it "returns deserialized value from HTML comment" do
      expect(described_class.deserialize(html)).to eq(value)
    end
  end
end
