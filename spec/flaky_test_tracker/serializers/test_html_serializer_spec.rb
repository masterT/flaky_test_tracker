# frozen_string_literal: true

RSpec.describe FlakyTestTracker::Serializers::TestHTMLSerializer do
  subject { described_class.new(html_serializer: html_serializer) }

  let(:html_serializer) { instance_double(FlakyTestTracker::Serializers::HTMLCommentSerializer) }
  let(:test) { build(:test) }
  let(:test_html) { "<!-- html -->" }
  let(:test_json) do
    JSON.generate(
      "id" => test.id,
      "url" => test&.url,
      "reference" => test.reference,
      "description" => test.description,
      "exception" => test.exception,
      "file_path" => test.file_path,
      "line_number" => test.line_number,
      "source_location_url" => test.source_location_url,
      "number_occurrences" => test.number_occurrences,
      "finished_at" => test.finished_at.iso8601(9),
      "resolved_at" => test.resolved_at&.iso8601(9)
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
            FlakyTestTracker::Serializers::HTMLCommentSerializer
          )
        )
      end
    end
  end

  describe "#serialize" do
    before do
      allow(html_serializer).to receive(:serialize).and_return(test_html)
    end

    context "when Test is resolved" do
      let(:test) { build(:test, resolved_at: Time.current) }

      it "serializes Test attributes as JSON" do
        subject.serialize(test)

        expect(html_serializer).to have_received(:serialize).with(test_json)
      end
    end

    context "when Test is not resolved" do
      it "serializes Test attributes as JSON" do
        subject.serialize(test)

        expect(html_serializer).to have_received(:serialize).with(test_json)
      end
    end

    it "returns HTML" do
      expect(subject.serialize(test)).to eq test_html
    end
  end

  describe "#deserialize" do
    before do
      allow(html_serializer).to receive(:deserialize).and_return(test_json)
    end

    context "when Test is resolved" do
      let(:test) { build(:test, resolved_at: Time.current) }

      it "deserialize Test attributes as JSON" do
        subject.deserialize(test_html)

        expect(html_serializer).to have_received(:deserialize).with(test_html)
      end
    end

    context "when Test is not resolved" do
      it "deserialize Test attributes as JSON" do
        subject.deserialize(test_html)

        expect(html_serializer).to have_received(:deserialize).with(test_html)
      end
    end

    it "returns Test" do
      expect(subject.deserialize(test_html)).to eq(test)
    end
  end
end
