# frozen_string_literal: true

RSpec.describe FlakyTestTracker::TestInputFactory do
  subject { described_class.new }

  describe "#build" do
    subject { described_class.new }

    let(:test) { build(:test) }
    let(:source) { spy("source") }
    let(:attributes) do
      attributes_for(:test_input).except(
        :resolved_at,
        :number_occurrences,
        :source_location_url
      )
    end

    let(:file_source_location_uri) do
      URI("https://github.com/foo/bar/blob/0612bcf5b16a1ec368ef4ebb92d6be2f7040260b/spec/foo_spec.rb")
    end

    before do
      allow(source).to receive(:file_source_location_uri).and_return(file_source_location_uri)
    end

    it "generates source_location_url" do
      subject.build(test: test, source: source, attributes: attributes)

      expect(source).to have_received(:file_source_location_uri).with(
        file_path: attributes[:file_path],
        line_number: attributes[:line_number]
      )
    end

    it "returns FlakyTestTracker::TestInput with attributes" do
      expect(subject.build(test: test, source: source, attributes: attributes)).to be_a(
        FlakyTestTracker::TestInput
      ).and(
        have_attributes(attributes)
      )
    end

    context "when Test is present" do
      it "returns FlakyTestTracker::TestInput with attribute number_occurrences incremented" do
        expect(subject.build(test: test, source: source, attributes: attributes)).to be_a(
          FlakyTestTracker::TestInput
        ).and(
          have_attributes(
            number_occurrences: test.number_occurrences + 1
          )
        )
      end

      context "when Test is not resolved" do
        let(:test) { build(:test, resolved_at: nil) }

        it "returns FlakyTestTracker::TestInput with attribute resolved_at equals nil" do
          expect(subject.build(test: test, source: source, attributes: attributes)).to be_a(
            FlakyTestTracker::TestInput
          ).and(
            have_attributes(
              resolved_at: nil
            )
          )
        end
      end

      context "when Test is resolved" do
        let(:test) { build(:test, resolved_at: Time.now) }

        it "returns FlakyTestTracker::TestInput with attribute resolved_at equals nil" do
          expect(subject.build(test: test, source: source, attributes: attributes)).to be_a(
            FlakyTestTracker::TestInput
          ).and(
            have_attributes(
              resolved_at: nil,
              number_occurrences: test.number_occurrences + 1
            )
          )
        end
      end
    end

    context "when Test is nil" do
      let(:test) { nil }

      it "returns FlakyTestTracker::TestInput with attributes number_occurrences incremented" do
        expect(subject.build(test: test, source: source, attributes: attributes)).to be_a(
          FlakyTestTracker::TestInput
        ).and(
          have_attributes(
            number_occurrences: 1
          )
        )
      end
    end
  end
end
