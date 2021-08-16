# frozen_string_literal: true

RSpec.describe FlakyTestTracker::Serializers::TestInputHTMLSerializer do
  subject { described_class.new(html_serializer: html_serializer) }

  let(:html_serializer) { instance_double(FlakyTestTracker::Serializers::HTMLSerializer) }
  let(:test_input) { build(:test_input) }
  let(:test_input_html) { "<!-- html -->" }
  let(:test_input_json) do
    JSON.generate(
      "reference" => test_input.reference,
      "description" => test_input.description,
      "exception" => test_input.exception,
      "file_path" => test_input.file_path,
      "line_number" => test_input.line_number,
      "source_location_url" => test_input.source_location_url,
      "number_occurrences" => test_input.number_occurrences,
      "finished_at" => test_input.finished_at.iso8601(9)
    )
  end

  describe "::new" do
    it "sets attributes" do
      expect(
        described_class.new(
          html_serializer: html_serializer
        )
      ).to have_attributes(
        html_serializer: html_serializer
      )
    end

    context "without required attributes" do
      it "sets defaults attributes" do
        expect(
          described_class.new
        ).to have_attributes(
          html_serializer: an_instance_of(
            FlakyTestTracker::Serializers::HTMLSerializer
          )
        )
      end
    end
  end

  describe "#serialize" do
    before do
      allow(html_serializer).to receive(:serialize).and_return(test_input_html)
    end

    it "serializes TestInput attributes as JSON" do
      subject.serialize(test_input)

      expect(html_serializer).to have_received(:serialize).with(test_input_json)
    end

    it "returns HTML" do
      expect(subject.serialize(test_input)).to eq test_input_html
    end
  end

  describe "#deserialize" do
    before do
      allow(html_serializer).to receive(:deserialize).and_return(test_input_json)
    end

    it "deserialize TestInput attributes as JSON" do
      subject.deserialize(test_input_html)

      expect(html_serializer).to have_received(:deserialize).with(test_input_html)
    end

    it "returns TestInput" do
      expect(subject.deserialize(test_input_html)).to eq(test_input)
    end
  end
end
