# frozen_string_literal: true

RSpec.describe FlakyTestTracker do
  it "has a version number" do
    expect(FlakyTestTracker::VERSION).not_to be nil
  end

  describe "::confinement" do
    let(:arguments) do
      {
        test_repository: {
          type: :github_issue,
          options: {
            client: { access_token: "0612bcf5b16a1ec368ef4ebb92d6be2f7040260b" },
            repository: "foo/bar",
            labels: ["flaky"],
            title_template: "<%= test.reference %>",
            body_template: "<%= test.reference %>"
          }
        },
        context: {},
        source: {
          type: :github,
          options: {
            host: "mygithub.com",
            repository: "foo/bar",
            commit: "0612bcf5b16a1ec368ef4ebb92d6be2f7040260b",
            branch: "main"
          }
        },
        verbose: true,
        reporters: [FlakyTestTracker::Reporters::BaseReporter.new]
      }
    end

    it "returns an instance of FlakyTestTracker::Confinement" do
      expect(described_class.confinement(**arguments)).to be_a(FlakyTestTracker::Confinement)
    end
  end

  describe "::deconfinement" do
    let(:arguments) do
      {
        test_repository: {
          type: :github_issue,
          options: {
            client: { access_token: "0612bcf5b16a1ec368ef4ebb92d6be2f7040260b" },
            repository: "foo/bar",
            labels: ["flaky"],
            title_template: "<%= test.reference %>",
            body_template: "<%= test.reference %>"
          }
        },
        verbose: true,
        reporters: [FlakyTestTracker::Reporters::BaseReporter.new],
        confinement_duration: 86_400 * 10
      }
    end

    it "returns an instance of FlakyTestTracker::Deconfinement" do
      expect(described_class.deconfinement(**arguments)).to be_a(FlakyTestTracker::Deconfinement)
    end
  end

  describe "::test_repository" do
    let(:type) { nil }
    let(:options) { {} }
    let(:arguments) do
      {
        type: type,
        options: options
      }
    end

    context "when type github_issue" do
      let(:type) { :github_issue }
      let(:options) do
        {
          client: { access_token: "0612bcf5b16a1ec368ef4ebb92d6be2f7040260b" },
          repository: "foo/bar",
          labels: ["flaky"],
          title_template: "<%= test.reference %>",
          body_template: "<%= test.reference %>"
        }
      end

      it "returns an instance of FlakyTestTracker::Repositories::Test::GitHubIssueRepository" do
        expect(described_class.test_repository(**arguments)).to be_a(
          FlakyTestTracker::Repositories::Test::GitHubIssueRepository
        )
      end
    end

    context "when type is unkown" do
      let(:type) { :unkown_type }

      it "raise an ArgumentError" do
        expect { described_class.test_repository(**arguments) }.to raise_error(ArgumentError, /unkown .* type/i)
      end
    end
  end

  describe "::source" do
    let(:type) { nil }
    let(:options) { {} }
    let(:arguments) do
      {
        type: type,
        options: options
      }
    end

    context "when type github" do
      let(:type) { :github }
      let(:options) do
        {
          host: "mygithub.com",
          repository: "foo/bar",
          commit: "0612bcf5b16a1ec368ef4ebb92d6be2f7040260b",
          branch: "main"
        }
      end

      it "returns an instance of FlakyTestTracker::Sources::GitHubSource" do
        expect(described_class.source(**arguments)).to be_a(FlakyTestTracker::Sources::GitHubSource)
      end
    end

    context "when type is unkown" do
      let(:type) { :unkown_type }

      it "raise an ArgumentError" do
        expect { described_class.source(**arguments) }.to raise_error(ArgumentError, /unkown .* type/i)
      end
    end
  end

  describe "::reporter" do
    let(:reporter) { FlakyTestTracker::Reporters::BaseReporter.new }
    let(:reporters) { [reporter] }
    let(:verbose) { false }
    let(:arguments) do
      {
        reporters: reporters,
        verbose: verbose
      }
    end

    context "when verbose true" do
      let(:verbose) { true }

      it "creates an reporter without reporters + FlakyTestTracker::Reporters::STDOUTReporter" do
        expect(described_class.reporter(**arguments)).to be_a(FlakyTestTracker::Reporter).and(
          have_attributes(
            reporters: a_collection_containing_exactly(
              reporter,
              an_instance_of(FlakyTestTracker::Reporters::STDOUTReporter)
            )
          )
        )
      end
    end

    context "when verbose false" do
      let(:verbose) { false }

      it "creates an reporter with reporters" do
        expect(described_class.reporter(**arguments)).to be_a(FlakyTestTracker::Reporter).and(
          have_attributes(
            reporters: a_collection_containing_exactly(
              reporter
            )
          )
        )
      end
    end

    context "with only required attributes" do
      let(:arguments) { {} }

      it "creates an reporter without reporters" do
        expect(described_class.reporter(**arguments)).to be_a(FlakyTestTracker::Reporter).and(
          have_attributes(
            reporters: []
          )
        )
      end
    end
  end
end
