# frozen_string_literal: true

RSpec.describe FlakyTestTracker do
  it "has a version number" do
    expect(FlakyTestTracker::VERSION).not_to be nil
  end

  describe "::configure" do
    it "yields with configuration" do
      expect { |b| described_class.configure(&b) }.to yield_with_args(FlakyTestTracker.configuration)
    end
  end

  describe "::tracker" do
    let(:configuration) do
      instance_double(
        FlakyTestTracker::Configuration,
        pretend: true,
        storage: double("storage"),
        context: double("context"),
        source: double("source"),
        reporter: double("reporter")
      )
    end

    before do
      described_class.configuration = configuration
    end

    after do
      described_class.reset
    end

    it "returns an instance of FlakyTestTracker::Tracker" do
      expect(described_class.tracker).to be_a(FlakyTestTracker::Tracker).and(
        have_attributes(
          pretend: configuration.pretend,
          storage: configuration.storage,
          context: configuration.context,
          source: configuration.source,
          reporter: configuration.reporter
        )
      )
    end
  end

  describe "::resolver" do
    let(:configuration) do
      instance_double(
        FlakyTestTracker::Configuration,
        pretend: true,
        storage: double("storage"),
        reporter: double("reporter")
      )
    end

    before do
      described_class.configuration = configuration
    end

    after do
      described_class.reset
    end

    it "returns an instance of FlakyTestTracker::Resolver" do
      expect(described_class.resolver).to be_a(FlakyTestTracker::Resolver).and(
        have_attributes(
          pretend: configuration.pretend,
          storage: configuration.storage,
          reporter: configuration.reporter
        )
      )
    end
  end
end
