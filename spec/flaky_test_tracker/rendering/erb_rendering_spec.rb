# frozen_string_literal: true

require "erb"

RSpec.describe FlakyTestTracker::Rendering::ERBRendering do
  subject { described_class.new(template: template) }

  let(:template) { "<%= foo %>" }
  let(:erb) { ERB.new(template) }

  describe "::new" do
    it "set attributes erb" do
      expect(
        described_class.new(
          template: template
        )
      ).to have_attributes(
        erb: an_instance_of(ERB).and(
          have_attributes(
            src: erb.src,
            encoding: erb.encoding
          )
        )
      )
    end
  end

  describe "#output" do
    let(:locals) { { foo: "bar" } }

    it "calls result on erb with binding" do
      allow(subject.erb).to receive(:result)

      subject.output(**locals)

      expect(subject.erb).to have_received(:result).with(
        an_instance_of(Binding)
      )
    end

    it "returns result" do
      expect(subject.output(**locals)).to eq "bar"
    end
  end
end
