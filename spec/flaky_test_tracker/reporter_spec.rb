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

  describe "deconfined_test" do
    let(:confinement_duration) { 40 * 86_400 }

    it "report to reporters" do
      subject.deconfined_test(
        test: test,
        confinement_duration: confinement_duration
      )

      expect(reporter).to have_received(:deconfined_test).with(
        test: test,
        confinement_duration: confinement_duration
      )
    end
  end

  describe "deconfined_tests" do
    let(:confinement_duration) { 40 * 86_400 }
    let(:tests) { [test] }

    it "report to reporters" do
      subject.deconfined_tests(
        tests: tests,
        confinement_duration: confinement_duration
      )

      expect(reporter).to have_received(:deconfined_tests).with(
        tests: tests,
        confinement_duration: confinement_duration
      )
    end
  end
end
