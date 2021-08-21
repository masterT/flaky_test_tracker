# frozen_string_literal: true

require "erb"

RSpec.describe FlakyTestTracker::Rendering do
  subject { described_class.new(template: template) }

  let(:template) { "<%= foo %>" }
  let(:erb) { ERB.new(template) }

  describe "#output" do
    let(:locals) { { foo: "bar" } }

    # TODO: Add better test.

    it "returns result" do
      expect(subject.output(**locals)).to eq "bar"
    end
  end
end
