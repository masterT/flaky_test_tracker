# frozen_string_literal: true

RSpec.describe FlakyTestTracker::Deconfinement do
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
      deconfined_test: nil,
      deconfined_tests: nil
    )
  end

  describe "#deconfine" do
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
        subject.deconfine

        expect(storage).to have_received(:all)
      end

      context "when finished at < Time.now - confinement_duration" do
        let(:test) do
          build(:test, finished_at: now - confinement_duration - 1)
        end

        before do
          allow(storage).to receive(:delete).and_return(test_deleted)
        end

        it "report deconfined_test" do
          subject.deconfine

          expect(reporter).to have_received(:deconfined_test).with(
            test: test_deleted,
            confinement_duration: confinement_duration
          )
        end

        it "report deconfined_tests" do
          subject.deconfine

          expect(reporter).to have_received(:deconfined_tests).with(
            tests: [test_deleted],
            confinement_duration: confinement_duration
          )
        end

        it "deletes the Test" do
          subject.deconfine

          expect(storage).to have_received(:delete).with(test.id)
        end

        it "returns deleted Test" do
          expect(subject.deconfine).to containing_exactly(test_deleted)
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
          subject.deconfine

          expect(storage).to have_received(:delete).with(test.id)
        end

        it "report deconfined_test" do
          subject.deconfine

          expect(reporter).to have_received(:deconfined_test).with(
            test: test_deleted,
            confinement_duration: confinement_duration
          )
        end

        it "report deconfined_tests" do
          subject.deconfine

          expect(reporter).to have_received(:deconfined_tests).with(
            tests: [test_deleted],
            confinement_duration: confinement_duration
          )
        end

        it "returns deleted Test" do
          expect(subject.deconfine).to containing_exactly(test_deleted)
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
          subject.deconfine

          expect(storage).not_to have_received(:delete)
        end

        it "returns empty" do
          expect(subject.deconfine).to be_empty
        end
      end
    end
  end
end
