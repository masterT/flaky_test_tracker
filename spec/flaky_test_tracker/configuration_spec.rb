# frozen_string_literal: true

RSpec.describe FlakyTestTracker::Configuration do
  subject { described_class.new }

  describe "#source_class_name=" do
    let(:source_class_name) { "SourceClass" }
    let(:source_class) do
      Class.new do
        def self.build
          new
        end
      end
    end

    before do
      stub_const(source_class_name, source_class)
    end

    it "retreives class and sets source_class" do
      expect { subject.source_class_name = source_class_name }.to change(subject, :source_class).to(source_class)
    end

    context "when class does not repond to ::build" do
      let(:source_class) { Class.new }

      it "raises an ArgumentError" do
        expect { subject.source_class_name = source_class_name }.to raise_error(ArgumentError, /build/i)
      end
    end
  end

  describe "#source_type=" do
    context "with kown source_type" do
      context "when github" do
        let(:source_type) { "github" }

        it "sets source_class to FlakyTestTracker::Source::GitHubSource" do
          expect do
            subject.source_type = source_type
          end.to change(subject, :source_class).to(FlakyTestTracker::Source::GitHubSource)
        end
      end
    end
    context "with unkown source_type" do
      let(:source_type) { "unkown" }

      it "raises an ArgumentError" do
        expect { subject.source_type = source_type }.to raise_error(ArgumentError, /unkown/i)
      end
    end
  end

  describe "#source_class=" do
    let(:source_class) do
      Class.new do
        def self.build
          new
        end
      end
    end

    it "sets source_class" do
      expect { subject.source_class = source_class }.to change(subject, :source_class).to(source_class)
    end

    context "when class does not repond to ::build" do
      let(:source_class) { Class.new }

      it "raises an ArgumentError" do
        expect { subject.source_class = source_class }.to raise_error(ArgumentError, /build/i)
      end
    end
  end

  describe "#source_options=" do
    let(:source_options) { { foo: "bar" } }

    it "sets source_options" do
      expect { subject.source_options = source_options }.to change(subject, :source_options).to(source_options)
    end

    context "when source_options is not a Hash" do
      let(:source_options) { nil }

      it "raises an ArgumentError" do
        expect { subject.source_options = source_options }.to raise_error(ArgumentError, /hash/i)
      end
    end
  end

  describe "#source=" do
    let(:source) do
      double(
        "source",
        file_source_location_uri: nil,
        source_uri: nil
      )
    end

    it "sets source" do
      subject.source = source

      expect(subject.source).to eql source
    end

    context "when source does not respond to #file_source_location_uri, #source_uri" do
      let(:source) { double("source") }

      it "raises an ArgumentError" do
        expect { subject.source = source }.to raise_error(ArgumentError, /respond to/i)
      end
    end
  end

  describe "#source" do
    let(:source_options) { { foo: "bar" } }
    let(:source_class) do
      Class.new do
        def self.build(foo:)
          new(foo: foo)
        end

        attr_accessor :foo

        def initialize(foo:)
          @foo = foo
        end

        def source_uri; end

        def file_source_location_uri; end
      end
    end

    context "when source_class and source_options are set" do
      before do
        subject.source_class = source_class
        subject.source_options = source_options
      end

      it "calls build on the source_class" do
        allow(source_class).to receive(:build).and_call_original

        subject.source

        expect(source_class).to have_received(:build).with(source_options)
      end

      it "returns build source" do
        expect(subject.source).to be_a(source_class).and(
          have_attributes(source_options)
        )
      end
    end
  end

  describe "#storage_class_name=" do
    let(:storage_class_name) { "SourceClass" }
    let(:storage_class) do
      Class.new do
        def self.build
          new
        end
      end
    end

    before do
      stub_const(storage_class_name, storage_class)
    end

    it "retreives class and sets storage_class" do
      expect { subject.storage_class_name = storage_class_name }.to change(subject, :storage_class).to(storage_class)
    end

    context "when class does not repond to ::build" do
      let(:storage_class) { Class.new }

      it "raises an ArgumentError" do
        expect { subject.storage_class_name = storage_class_name }.to raise_error(ArgumentError, /build/i)
      end
    end
  end

  describe "#storage_type=" do
    context "with kown storage_type" do
      context "when github_issue" do
        let(:storage_type) { "github_issue" }

        it "sets storage_class to FlakyTestTracker::Storage::GitHubIssueStorage" do
          expect { subject.storage_type = storage_type }.to change(subject, :storage_class).to(
            FlakyTestTracker::Storage::GitHubIssueStorage
          )
        end
      end
    end
    context "with unkown storage_type" do
      let(:storage_type) { "unkown" }

      it "raises an ArgumentError" do
        expect { subject.storage_type = storage_type }.to raise_error(ArgumentError, /unkown/i)
      end
    end
  end

  describe "#storage_class=" do
    let(:storage_class) do
      Class.new do
        def self.build
          new
        end
      end
    end

    it "sets storage_class" do
      expect { subject.storage_class = storage_class }.to change(subject, :storage_class).to(storage_class)
    end

    context "when class does not repond to ::build" do
      let(:storage_class) { Class.new }

      it "raises an ArgumentError" do
        expect { subject.storage_class = storage_class }.to raise_error(ArgumentError, /build/i)
      end
    end
  end

  describe "#storage_options=" do
    let(:storage_options) { { foo: "bar" } }

    it "sets storage_options" do
      expect { subject.storage_options = storage_options }.to change(subject, :storage_options).to(storage_options)
    end

    context "when storage_options is not a Hash" do
      let(:storage_options) { nil }

      it "raises an ArgumentError" do
        expect { subject.storage_options = storage_options }.to raise_error(ArgumentError, /hash/i)
      end
    end
  end

  describe "#storage=" do
    let(:storage) do
      double(
        "storage",
        all: nil,
        create: nil,
        update: nil,
        delete: nil
      )
    end

    it "sets storage" do
      subject.storage = storage

      expect(subject.storage).to eql storage
    end

    context "when storage does not respond to #all, #create, #update, #delete" do
      let(:storage) { double("storage") }

      it "raises an ArgumentError" do
        expect { subject.storage = storage }.to raise_error(ArgumentError, /respond to/i)
      end
    end
  end

  describe "#storage" do
    let(:storage_options) { { foo: "bar" } }
    let(:storage_class) do
      Class.new do
        def self.build(foo:)
          new(foo: foo)
        end

        attr_accessor :foo

        def initialize(foo:)
          @foo = foo
        end

        def all; end

        def create; end

        def update; end

        def delete; end
      end
    end

    context "when storage_class and storage_options are set" do
      before do
        subject.storage_class = storage_class
        subject.storage_options = storage_options
      end

      it "calls build on the storage_class" do
        allow(storage_class).to receive(:build).and_call_original

        subject.storage

        expect(storage_class).to have_received(:build).with(storage_options)
      end

      it "returns build storage" do
        expect(subject.storage).to be_a(storage_class).and(
          have_attributes(storage_options)
        )
      end
    end
  end

  describe "#reporter_class_name=" do
    let(:reporter_class) do
      Class.new do
        def self.build
          new
        end
      end
    end
    let(:reporter_class_name) { "ReporterClass" }

    before do
      stub_const(reporter_class_name, reporter_class)
    end

    it "retreives class and sets reporter_class" do
      expect { subject.reporter_class_name = reporter_class_name }.to change(subject, :reporter_class).to(
        reporter_class
      )
    end

    context "when class does not repond to ::build" do
      let(:reporter_class) { Class.new }

      it "raises an ArgumentError" do
        expect { subject.reporter_class_name = reporter_class_name }.to raise_error(ArgumentError, /build/i)
      end
    end
  end

  describe "#reporter_class=" do
    let(:reporter_class) do
      Class.new do
        def self.build
          new
        end
      end
    end

    it "sets reporter_class" do
      expect { subject.reporter_class = reporter_class }.to change(subject, :reporter_class).to(reporter_class)
    end

    context "when class does not repond to ::build" do
      let(:reporter_class) { Class.new }

      it "raises an ArgumentError" do
        expect { subject.reporter_class = reporter_class }.to raise_error(ArgumentError, /build/i)
      end
    end
  end

  describe "#reporter_options=" do
    let(:reporter_options) { { foo: "bar" } }

    it "sets reporter_options" do
      expect { subject.reporter_options = reporter_options }.to change(subject, :reporter_options).to(reporter_options)
    end

    context "when reporter_options is not a Hash" do
      let(:reporter_options) { nil }

      it "raises an ArgumentError" do
        expect { subject.reporter_options = reporter_options }.to raise_error(ArgumentError, /hash/i)
      end
    end
  end

  describe "#reporter=" do
    let(:reporter) do
      double(
        "reporter",
        tracked_tests: nil,
        resolved_tests: nil
      )
    end

    it "sets reporter" do
      subject.reporter = reporter

      expect(subject.reporter).to eql reporter
    end

    context "when reporter does not respond to #tracked_tests, #resolved_tests" do
      let(:reporter) { double("reporter") }

      it "raises an ArgumentError" do
        expect { subject.reporter = reporter }.to raise_error(ArgumentError, /respond to/i)
      end
    end
  end

  describe "#reporter" do
    let(:reporter_options) { { foo: "bar" } }
    let(:reporter_class) do
      Class.new do
        def self.build(foo:)
          new(foo: foo)
        end

        attr_accessor :foo

        def initialize(foo:)
          @foo = foo
        end

        def tracked_tests(tests:, source:, context:); end

        def resolved_tests(tests:); end
      end
    end

    context "when reporter_class and reporter_options are set" do
      before do
        subject.reporter_class = reporter_class
        subject.reporter_options = reporter_options
      end

      it "calls build on the reporter_class" do
        allow(reporter_class).to receive(:build).and_call_original

        subject.reporter

        expect(reporter_class).to have_received(:build).with(reporter_options)
      end

      it "returns built reporter" do
        expect(subject.reporter).to be_a(reporter_class).and(
          have_attributes(reporter_options)
        )
      end
    end
  end
end
