# frozen_string_literal: true

RSpec.describe FlakyTestTracker::Resolver do
  subject do
    described_class.new(
      pretend: pretend,
      storage: storage,
      reporter: reporter,
      verbose: verbose
    )
  end

  let(:pretend) { false }
  let(:verbose) { false }
  let(:storage) { spy("storage") }
  let(:reporter) do
    instance_double(
      FlakyTestTracker::Reporter::BaseReporter,
      resolved_tests: nil
    )
  end

  describe "#resolve" do
    let(:now) { Time.now }

    before do
      allow(Time).to receive(:now).and_return(now)
    end

    context "with Test" do
      let(:test) { build(:test) }
      let(:test_resolved) do
        build(
          :test,
          test.serializable_hash.merge(resolved_at: Time.now)
        )
      end

      before do
        allow(storage).to receive(:all).and_return([test])
      end

      it "fetch tests from storage" do
        subject.resolve { true }

        expect(storage).to have_received(:all)
      end

      it "yield block with Test" do
        expect { |b| subject.resolve(&b) }.to yield_with_args(test)
      end

      context "when Test already resolved" do
        let(:test) { build(:test, resolved_at: Time.now) }

        it "does not yield block with resolkved Test" do
          expect { |b| subject.resolve(&b) }.not_to yield_with_args(test)
        end
      end

      context "when block result is true" do
        let(:result) { true }

        before do
          allow(storage).to receive(:update).and_return(test_resolved)
        end

        it "report resolved_tests" do
          subject.resolve { result }

          expect(reporter).to have_received(:resolved_tests).with(tests: [test_resolved])
        end

        context "when verbose is true" do
          let(:verbose) { true }

          it "outputs to STDOUT" do
            expect { subject.resolve { result } }.to output(
              "\n[FlakyTestTracker][Resolver] 1 test(s) resolved\n"
            ).to_stdout
          end
        end

        context "when verbose is false" do
          let(:verbose) { false }

          it "does not output to STDOUT" do
            expect { subject.resolve { result } }.not_to output.to_stdout
          end
        end

        it "updates the Test with resolved_at" do
          subject.resolve { result }

          expect(storage).to have_received(:update).with(
            test.id,
            FlakyTestTracker::TestInput.new(
              test.serializable_hash(except: %i[id url]).merge(
                resolved_at: Time.now
              )
            )
          )
        end

        it "returns updated Test" do
          expect(subject.resolve { result }).to containing_exactly(test_resolved)
        end

        context "when pretend" do
          let(:pretend) { true }

          it "does not update the Test" do
            subject.resolve { result }

            expect(storage).not_to have_received(:update)
          end

          it "returns Test" do
            expect(subject.resolve { result }).to containing_exactly(test)
          end
        end
      end

      context "when block result is false" do
        let(:result) { false }

        before do
          allow(storage).to receive(:delete).and_return(test_resolved)
        end

        it "does not delete the Test" do
          subject.resolve { result }

          expect(storage).not_to have_received(:delete)
        end

        it "returns empty" do
          expect(subject.resolve { result }).to be_empty
        end
      end
    end
  end
end
