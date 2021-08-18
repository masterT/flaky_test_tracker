# frozen_string_literal: true

RSpec.describe FlakyTestTracker::Confinement do
  subject do
    described_class.new(
      test_repository: test_repository,
      context: context,
      source: source,
      reporter: reporter
    )
  end

  let(:test_repository) { spy("test_repository") }
  let(:context) { spy("context") }
  let(:source) { spy("source") }
  let(:reporter) do
    instance_double(
      FlakyTestTracker::Reporter,
      confined_test: nil,
      confined_tests: nil
    )
  end

  describe "#tests" do
    let(:test) { build(:test) }

    before do
      allow(test_repository).to receive(:all).and_return([test])
    end

    it "returns tests from test_repository" do
      expect(subject.tests).to eq [test]
    end
  end

  describe "#add" do
    let(:test_input_attributes) do
      attributes_for(:test_input).except(
        :number_occurrences,
        :source_location_url
      )
    end

    it "adds attributes to test_inputs_attributes" do
      subject.add(**test_input_attributes)

      expect(subject.test_inputs_attributes).to containing_exactly(test_input_attributes)
    end

    context "with only required attributes" do
      let(:now) { Time.now }
      let(:attributes) do
        attributes_for(:test_input).except(
          :finished_at,
          :number_occurrences,
          :source_location_url
        )
      end

      before do
        allow(Time).to receive(:now).and_return(now)
      end

      it "adds attributes to test_inputs_attributes with default" do
        subject.add(**test_input_attributes)

        expect(subject.test_inputs_attributes).to containing_exactly(
          test_input_attributes.merge(
            finished_at: now
          )
        )
      end
    end
  end

  describe "#confine" do
    context "when TestInput attributes added" do
      let(:source_location_uri) { URI("https://github.com/foo/bar/blob/0612bcf5b16a1ec368ef4ebb92d6be2f7040260b/spec/foo_spec.rb") }
      let(:test_input_attributes) do
        attributes_for(:test_input).except(
          :number_occurrences,
          :source_location_url
        )
      end

      before do
        subject.add(**test_input_attributes)

        allow(source).to receive(:source_location_uri).and_return(source_location_uri)
      end

      context "when TestInput attributes invalid" do
        let(:test_input_attributes) do
          {
            reference: nil,
            description: nil,
            exception: nil,
            file_path: nil,
            line_number: nil,
            finished_at: nil
          }
        end

        it "raises an ActiveModel::ValidationError" do
          expect { subject.confine }.to raise_error(ActiveModel::ValidationError)
        end
      end

      context "when Test with the same reference exists" do
        let(:test) { build(:test, test_input_attributes) }
        let(:test_updated) do
          build(
            :test,
            test.serializable_hash.merge(
              source_location_url: source_location_uri.to_s,
              number_occurrences: test.number_occurrences + 1
            )
          )
        end

        before do
          allow(test_repository).to receive(:all).and_return([test])
          allow(test_repository).to receive(:update).and_return(test_updated)
        end

        it "generates source_location_url" do
          subject.confine

          expect(source).to have_received(:source_location_uri).with(
            file_path: test_input_attributes[:file_path],
            line_number: test_input_attributes[:line_number]
          )
        end

        it "updates Test with number_occurrences incremented by 1" do
          subject.confine

          expect(test_repository).to have_received(:update).with(
            test.id,
            FlakyTestTracker::Inputs::TestInput.new(
              test_input_attributes.merge(
                number_occurrences: test.number_occurrences + 1,
                source_location_url: source_location_uri.to_s
              )
            )
          )
        end

        it "report confined_test" do
          subject.confine

          expect(reporter).to have_received(:confined_test).with(
            test: test_updated,
            source: source,
            context: context
          )
        end

        it "report confined_tests" do
          subject.confine

          expect(reporter).to have_received(:confined_tests).with(
            tests: [test_updated],
            source: source,
            context: context
          )
        end

        it "returns updated Tests" do
          expect(subject.confine).to containing_exactly(test_updated)
        end
      end

      context "when Test with the same reference exists" do
        let(:test) { build(:test, reference: "another-test-reference") }
        let(:test_created) do
          build(
            :test,
            test.serializable_hash.merge(
              source_location_url: source_location_uri.to_s,
              number_occurrences: test.number_occurrences + 1
            )
          )
        end

        before do
          allow(test_repository).to receive(:all).and_return([test])
          allow(test_repository).to receive(:create).and_return(test_created)
        end

        it "generates source_location_url" do
          subject.confine

          expect(source).to have_received(:source_location_uri).with(
            file_path: test_input_attributes[:file_path],
            line_number: test_input_attributes[:line_number]
          )
        end

        it "updates Test with number_occurrences equals to 1" do
          subject.confine

          expect(test_repository).to have_received(:create).with(
            FlakyTestTracker::Inputs::TestInput.new(
              test_input_attributes.merge(
                number_occurrences: 1,
                source_location_url: source_location_uri.to_s
              )
            )
          )
        end

        it "report confined_test" do
          subject.confine

          expect(reporter).to have_received(:confined_test).with(
            test: test_created,
            source: source,
            context: context
          )
        end

        it "report confined_tests" do
          subject.confine

          expect(reporter).to have_received(:confined_tests).with(
            tests: [test_created],
            source: source,
            context: context
          )
        end

        it "returns created Tests" do
          expect(subject.confine).to containing_exactly(test_created)
        end
      end
    end

    describe "#clear" do
      context "when TestInput attributes added" do
        let(:test_input_attributes) do
          attributes_for(:test_input).except(
            :number_occurrences,
            :source_location_url
          )
        end

        before do
          subject.add(**test_input_attributes)
        end

        it "clear test_inputs_attributes" do
          subject.clear

          expect(subject.test_inputs_attributes).to be_empty
        end
      end
    end
  end
end
