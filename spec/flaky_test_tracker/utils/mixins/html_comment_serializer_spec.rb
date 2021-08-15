# frozen_string_literal: true

RSpec.describe FlakyTestTracker::Utils::Mixins::HTMLCommentSerializer do
  subject { test_class.new }

  let(:test_class) do
    Class.new do
      include FlakyTestTracker::Utils::Mixins::HTMLCommentSerializer
    end
  end

  let(:value) { "foo" }
  let(:html) do
    Nokogiri::XML::Comment.new(
      Nokogiri::HTML::Document.new,
      Base64.encode64(value)
    ).to_html
  end

  describe "#to_html_comment" do
    it "returns HTML comment representing the value" do
      expect(subject.to_html_comment(value)).to eq(html)
    end
  end

  describe "#from_html_comment" do
    it "returns deserialized value from HTML comment" do
      expect(subject.from_html_comment(html)).to eq(value)
    end
  end
end
