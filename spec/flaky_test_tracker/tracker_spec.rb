# frozen_string_literal: true

RSpec.describe FlakyTestTracker::Tracker do
  subject do
    described_class.new(
      pretend: pretend,
      storage: storage,
      context: context,
      source: source,
      reporter: reporter,
      verbose: verbose
    )
  end

  let(:pretend) { false }
  let(:verbose) { false }
  let(:storage) { spy("storage") }
  let(:context) { spy("context") }
  let(:source) { spy("source") }
  let(:reporter) do
    instance_double(
      FlakyTestTracker::Reporter::BaseReporter,
      tracked_tests: nil
    )
  end

  describe "#tests" do
    let(:test) { build(:test) }

    before do
      allow(storage).to receive(:all).and_return([test])
    end

    it "returns tests from storage" do
      expect(subject.tests).to eq [test]
    end
  end

  describe "#add" do
    let(:test_input_attributes) do
      attributes_for(:test_input).except(
        :resolved_at,
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

  describe "#track" do
    context "when TestInput attributes added" do
      let(:file_source_location_uri) do
        URI("https://github.com/foo/bar/blob/0612bcf5b16a1ec368ef4ebb92d6be2f7040260b/spec/foo_spec.rb")
      end
      let(:test_input_attributes) do
        attributes_for(:test_input).except(
          :resolved_at,
          :number_occurrences,
          :source_location_url
        )
      end

      before do
        subject.add(**test_input_attributes)

        allow(source).to receive(:file_source_location_uri).and_return(file_source_location_uri)
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
          expect { subject.track }.to raise_error(ActiveModel::ValidationError)
        end
      end

      context "when Test with the same reference exists" do
        let(:test) { build(:test, test_input_attributes) }
        let(:test_updated) do
          build(
            :test,
            test.serializable_hash.merge(
              resolved_at: nil,
              source_location_url: file_source_location_uri.to_s,
              number_occurrences: test.number_occurrences + 1
            )
          )
        end

        before do
          allow(storage).to receive(:all).and_return([test])
          allow(storage).to receive(:update).and_return(test_updated)
        end

        it "generates source_location_url" do
          subject.track

          expect(source).to have_received(:file_source_location_uri).with(
            file_path: test_input_attributes[:file_path],
            line_number: test_input_attributes[:line_number]
          )
        end

        it "updates Test with number_occurrences incremented by 1" do
          subject.track

          expect(storage).to have_received(:update).with(
            test.id,
            FlakyTestTracker::TestInput.new(
              test_input_attributes.merge(
                resolved_at: nil,
                number_occurrences: test.number_occurrences + 1,
                source_location_url: file_source_location_uri.to_s
              )
            )
          )
        end

        it "report tracked_tests" do
          subject.track

          expect(reporter).to have_received(:tracked_tests).with(
            tests: [test_updated],
            source: source,
            context: context
          )
        end

        context "when verbose is true" do
          let(:verbose) { true }

          it "outputs to STDOUT" do
            expect { subject.track }.to output(
              "\n[FlakyTestTracker][Tracker] 1 test(s) tracked\n"
            ).to_stdout
          end
        end

        context "when verbose is false" do
          let(:verbose) { false }

          it "does not output to STDOUT" do
            expect { subject.track }.not_to output.to_stdout
          end
        end

        it "returns updated Tests" do
          expect(subject.track).to containing_exactly(test_updated)
        end

        context "when pretend" do
          let(:pretend) { true }

          it "does not update Test" do
            subject.track

            expect(storage).not_to have_received(:update)
          end

          it "returns Tests found on storage" do
            expect(subject.track).to containing_exactly(test)
          end
        end
      end

      context "when Test with the same reference exists" do
        let(:test) { build(:test, reference: "another-test-reference") }
        let(:test_created) do
          build(
            :test,
            test.serializable_hash.merge(
              source_location_url: file_source_location_uri.to_s,
              number_occurrences: test.number_occurrences + 1
            )
          )
        end

        before do
          allow(storage).to receive(:all).and_return([test])
          allow(storage).to receive(:create).and_return(test_created)
        end

        it "generates source_location_url" do
          subject.track

          expect(source).to have_received(:file_source_location_uri).with(
            file_path: test_input_attributes[:file_path],
            line_number: test_input_attributes[:line_number]
          )
        end

        it "creates Test with number_occurrences equals to 1" do
          subject.track

          expect(storage).to have_received(:create).with(
            FlakyTestTracker::TestInput.new(
              test_input_attributes.merge(
                resolved_at: nil,
                number_occurrences: 1,
                source_location_url: file_source_location_uri.to_s
              )
            )
          )
        end

        it "report tracked_tests" do
          subject.track

          expect(reporter).to have_received(:tracked_tests).with(
            tests: [test_created],
            source: source,
            context: context
          )
        end

        it "returns created Tests" do
          expect(subject.track).to containing_exactly(test_created)
        end

        context "when pretend" do
          let(:pretend) { true }

          it "does not update Test" do
            subject.track

            expect(storage).not_to have_received(:create)
          end

          it "returns Tests initialized from TestInput attributes" do
            expect(subject.track).to containing_exactly(
              FlakyTestTracker::Test.new(test_input_attributes)
            )
          end
        end
      end
    end

    describe "#clear" do
      context "when TestInput attributes added" do
        let(:test_input_attributes) do
          attributes_for(:test_input).except(
            :resolved_at,
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
