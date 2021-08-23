# frozen_string_literal: true

RSpec.describe FlakyTestTracker::Resolver do
  subject do
    described_class.new(
      storage: storage,
      reporter: reporter,
      duration_period_without_failure: duration_period_without_failure
    )
  end

  let(:storage) { spy("storage") }
  let(:duration_period_without_failure) { 40 * 86_400 }
  let(:reporter) do
    instance_double(
      FlakyTestTracker::Reporter,
      resolved_test: nil,
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
      let(:test_resolved) { build(:test, test.serializable_hash) }

      before do
        allow(storage).to receive(:all).and_return([test])
      end

      it "fetch tests from storage" do
        subject.resolve

        expect(storage).to have_received(:all)
      end

      context "with block given" do
        it "yield block with Test" do
          expect { |b| subject.resolve(&b) }.to yield_with_args(test)
        end

        context "when block result is true" do
          let(:result) { true }

          before do
            allow(storage).to receive(:delete).and_return(test_resolved)
          end

          it "report resolved_test" do
            subject.resolve { result }

            expect(reporter).to have_received(:resolved_test).with(test: test_resolved)
          end

          it "report resolved_tests" do
            subject.resolve { result }

            expect(reporter).to have_received(:resolved_tests).with(tests: [test_resolved])
          end

          it "deletes the Test" do
            subject.resolve { result }

            expect(storage).to have_received(:delete).with(test.id)
          end

          it "returns deleted Test" do
            expect(subject.resolve { result }).to containing_exactly(test_resolved)
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

      context "without block given" do
        context "when finished at < Time.now - duration_period_without_failure" do
          let(:test) do
            build(:test, finished_at: now - duration_period_without_failure - 1)
          end

          before do
            allow(storage).to receive(:delete).and_return(test_resolved)
          end

          it "report resolved_test" do
            subject.resolve

            expect(reporter).to have_received(:resolved_test).with(test: test_resolved)
          end

          it "report resolved_tests" do
            subject.resolve

            expect(reporter).to have_received(:resolved_tests).with(tests: [test_resolved])
          end

          it "deletes the Test" do
            subject.resolve

            expect(storage).to have_received(:delete).with(test.id)
          end

          it "returns deleted Test" do
            expect(subject.resolve).to containing_exactly(test_resolved)
          end
        end

        context "when finished at = Time.now - duration_period_without_failure" do
          let(:test) do
            build(:test, finished_at: now - duration_period_without_failure)
          end

          before do
            allow(storage).to receive(:delete).and_return(test_resolved)
          end

          it "deletes the Test" do
            subject.resolve

            expect(storage).to have_received(:delete).with(test.id)
          end

          it "report resolved_test" do
            subject.resolve

            expect(reporter).to have_received(:resolved_test).with(test: test_resolved)
          end

          it "report resolved_tests" do
            subject.resolve

            expect(reporter).to have_received(:resolved_tests).with(tests: [test_resolved])
          end

          it "returns deleted Test" do
            expect(subject.resolve).to containing_exactly(test_resolved)
          end
        end

        context "when finished at > Time.now - duration_period_without_failure" do
          let(:test) do
            build(:test, finished_at: now - duration_period_without_failure + 1)
          end

          before do
            allow(storage).to receive(:delete).and_return(test_resolved)
          end

          it "does not delete the Test" do
            subject.resolve

            expect(storage).not_to have_received(:delete)
          end

          it "returns empty" do
            expect(subject.resolve).to be_empty
          end
        end
      end
    end
  end
end
