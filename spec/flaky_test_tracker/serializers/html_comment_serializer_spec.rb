# frozen_string_literal: true

RSpec.describe FlakyTestTracker::Serializers::HTMLCommentSerializer do
  subject { described_class.new }

  let(:value) { "foo" }
  let(:html) do
    "<!--#{Base64.strict_encode64(value)}-->"
    # Nokogiri::XML::Comment.new(
    #   Nokogiri::HTML::Document.new,
    #   Base64.strict_encode64(value)
    # ).to_html
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

    context "with invalid HTML" do
      let(:html) { "<i-Ls'='=>=<<<nvalid" }

      it "raises a FlakyTestTracker::Error::DeserializeError" do
        expect { subject.deserialize(html) }.to raise_error(FlakyTestTracker::Error::DeserializeError)
      end
    end

    context "with invalid HTML comment content" do
      let(:html) { "<!-- invalid -->" }

      it "raises a FlakyTestTracker::Error::DeserializeError" do
        expect { subject.deserialize(html) }.to raise_error(FlakyTestTracker::Error::DeserializeError)
      end
    end

    context "with HTML comment content encoded without strict" do
      let(:html) do
        "<!--#{Base64.encode64(value)}-->"
        # Nokogiri::XML::Comment.new(
        #   Nokogiri::HTML::Document.new,
        #   Base64.encode64(value)
        # ).to_html
      end

      it "returns deserialized value from HTML" do
        expect(subject.deserialize(html)).to eq(value)
      end
    end
  end
end
