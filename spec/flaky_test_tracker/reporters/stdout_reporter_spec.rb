# frozen_string_literal: true

RSpec.describe FlakyTestTracker::Reporters::STDOUTReporter do
  subject { described_class.new }
  let(:test) { build(:test) }
  let(:tests) { [test] }
  let(:context) { spy("context") }
  let(:source) { spy("source") }

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

  describe "#resolved_test" do
    it "does not output to STDOUT" do
      expect { subject.resolved_test(test: test) }.not_to output.to_stdout
    end
  end

  describe "#resolved_tests" do
    it "outputs to STDOUT" do
      expect { subject.resolved_tests(tests: tests) }.to \
        output("\n[FlakyTestTracker] #{tests.length} test(s) resolved\n").to_stdout
    end
  end
end
