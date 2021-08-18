# frozen_string_literal: true

RSpec.describe FlakyTestTracker::Reporter do
  subject { described_class.new(reporters: [reporter]) }

  let(:reporter) { spy("reporter") }
  let(:test) { build(:test) }
  let(:source) { spy("source") }
  let(:context) { spy("context") }

  describe "confined_test" do
    it "report to reporters" do
      subject.confined_test(
        test: test,
        source: source,
        context: context
      )

      expect(reporter).to have_received(:confined_test).with(
        test: test,
        source: source,
        context: context
      )
    end
  end

  describe "confined_tests" do
    let(:tests) { [test] }

    it "report to reporters" do
      subject.confined_tests(
        tests: tests,
        source: source,
        context: context
      )

      expect(reporter).to have_received(:confined_tests).with(
        tests: tests,
        source: source,
        context: context
      )
    end
  end
end
