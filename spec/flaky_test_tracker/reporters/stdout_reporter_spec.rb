# frozen_string_literal: true

RSpec.describe FlakyTestTracker::Reporters::STDOUTReporter do
  subject { described_class.new }
  let(:test) { build(:test) }
  let(:tests) { [test] }
  let(:context) { spy("context") }
  let(:source) { spy("source") }
  let(:confinement_duration) { 86_400 * 40 }

  describe "#tracked_test" do
    it "does not output to STDOUT" do
      expect { subject.tracked_test(test: test, source: source, context: context) }.not_to output.to_stdout
    end
  end

  describe "#tracked_tests" do
    it "outputs to STDOUT" do
      expect { subject.tracked_tests(tests: tests, source: source, context: context) }.to \
        output("\n[FlakyTestTracker] #{tests.length} test(s) tracked\n").to_stdout
    end
  end

  describe "#deconfined_test" do
    it "does not output to STDOUT" do
      expect { subject.deconfined_test(test: test, confinement_duration: confinement_duration) }.not_to output.to_stdout
    end
  end

  describe "#deconfined_tests" do
    it "outputs to STDOUT" do
      days = (confinement_duration / 86_400).round(2)

      expect { subject.deconfined_tests(tests: tests, confinement_duration: confinement_duration) }.to \
        output("\n[FlakyTestTracker] #{tests.length} test(s) deconfined after #{days} of confinement\n").to_stdout
    end
  end
end
