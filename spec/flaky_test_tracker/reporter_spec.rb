# frozen_string_literal: true

RSpec.describe FlakyTestTracker::Reporter do
  subject { described_class.new(reporters: [reporter]) }

  let(:reporter) { spy("reporter") }
  let(:test) { build(:test) }
  let(:source) { spy("source") }
  let(:context) { spy("context") }

  describe "tracked_test" do
    it "report to reporters" do
      subject.tracked_test(
        test: test,
        source: source,
        context: context
      )

      expect(reporter).to have_received(:tracked_test).with(
        test: test,
        source: source,
        context: context
      )
    end
  end

  describe "tracked_tests" do
    let(:tests) { [test] }

    it "report to reporters" do
      subject.tracked_tests(
        tests: tests,
        source: source,
        context: context
      )

      expect(reporter).to have_received(:tracked_tests).with(
        tests: tests,
        source: source,
        context: context
      )
    end
  end

  describe "resolved_test" do
    it "report to reporters" do
      subject.resolved_test(test: test)

      expect(reporter).to have_received(:resolved_test).with(test: test)
    end
  end

  describe "resolved_tests" do
    let(:tests) { [test] }

    it "report to reporters" do
      subject.resolved_tests(tests: tests)

      expect(reporter).to have_received(:resolved_tests).with(tests: tests)
    end
  end
end
