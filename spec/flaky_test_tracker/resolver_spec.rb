# frozen_string_literal: true

RSpec.describe FlakyTestTracker::Resolver do
  subject do
    described_class.new(
      storage: storage,
      reporter: reporter,
      confinement_duration: confinement_duration
    )
  end

  let(:storage) { spy("storage") }
  let(:confinement_duration) { 40 * 86_400 }
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
      let(:test_deleted) { build(:test, test.serializable_hash) }

      before do
        allow(storage).to receive(:all).and_return([test])
      end

      it "fetch tests from storage" do
        subject.resolve

        expect(storage).to have_received(:all)
      end

      context "when finished at < Time.now - confinement_duration" do
        let(:test) do
          build(:test, finished_at: now - confinement_duration - 1)
        end

        before do
          allow(storage).to receive(:delete).and_return(test_deleted)
        end

        it "report resolved_test" do
          subject.resolve

          expect(reporter).to have_received(:resolved_test).with(
            test: test_deleted,
            confinement_duration: confinement_duration
          )
        end

        it "report resolved_tests" do
          subject.resolve

          expect(reporter).to have_received(:resolved_tests).with(
            tests: [test_deleted],
            confinement_duration: confinement_duration
          )
        end

        it "deletes the Test" do
          subject.resolve

          expect(storage).to have_received(:delete).with(test.id)
        end

        it "returns deleted Test" do
          expect(subject.resolve).to containing_exactly(test_deleted)
        end
      end

      context "when finished at = Time.now - confinement_duration" do
        let(:test) do
          build(:test, finished_at: now - confinement_duration)
        end

        before do
          allow(storage).to receive(:delete).and_return(test_deleted)
        end

        it "deletes the Test" do
          subject.resolve

          expect(storage).to have_received(:delete).with(test.id)
        end

        it "report resolved_test" do
          subject.resolve

          expect(reporter).to have_received(:resolved_test).with(
            test: test_deleted,
            confinement_duration: confinement_duration
          )
        end

        it "report resolved_tests" do
          subject.resolve

          expect(reporter).to have_received(:resolved_tests).with(
            tests: [test_deleted],
            confinement_duration: confinement_duration
          )
        end

        it "returns deleted Test" do
          expect(subject.resolve).to containing_exactly(test_deleted)
        end
      end

      context "when finished at > Time.now - confinement_duration" do
        let(:test) do
          build(:test, finished_at: now - confinement_duration + 1)
        end

        before do
          allow(storage).to receive(:delete).and_return(test_deleted)
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
