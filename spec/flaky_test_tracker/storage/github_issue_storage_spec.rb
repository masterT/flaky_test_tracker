# frozen_string_literal: true

require "octokit"

RSpec.describe FlakyTestTracker::Storage::GitHubIssueStorage do
  subject do
    described_class.new(
      client: client,
      repository: repository,
      labels: labels,
      title_rendering: title_rendering,
      body_rendering: body_rendering,
      serializer: serializer
    )
  end

  let(:client) { instance_double(Octokit::Client) }
  let(:repository) { "foo/bar" }
  let(:labels) { ["flaky"] }
  let(:title_rendering) { spy("rendering", output: "title") }
  let(:body_rendering) { spy("rendering", output: "body") }
  let(:serializer) { spy("serializer") }

  describe "::build" do
    let(:options) do
      {
        client: { access_token: "0612bcf5b16a1ec368ef4ebb92d6be2f7040260b" },
        repository: "foo/bar",
        labels: ["flaky"],
        title_template: "<%= test.reference %>",
        body_template: "<%= test.reference %>"
      }
    end

    it "initializes a new instance with attributes" do
      expect(
        described_class.build(**options)
      ).to be_a(described_class).and(
        have_attributes(
          client: an_instance_of(Octokit::Client).and(
            have_attributes(
              options[:client].merge(auto_paginate: true)
            )
          ),
          repository: options[:repository],
          labels: options[:labels],
          title_rendering: an_instance_of(FlakyTestTracker::Rendering).and(
            have_attributes(
              template: options[:title_template]
            )
          ),
          body_rendering: an_instance_of(FlakyTestTracker::Rendering).and(
            have_attributes(
              template: options[:body_template]
            )
          ),
          serializer: an_instance_of(FlakyTestTracker::Serializers::TestHTMLSerializer)
        )
      )
    end

    context "with only required options" do
      let(:options) do
        {
          client: { access_token: "0612bcf5b16a1ec368ef4ebb92d6be2f7040260b" },
          repository: "foo/bar"
        }
      end

      it "initializes a new instance with default attributes" do
        expect(
          described_class.build(**options)
        ).to be_a(described_class).and(
          have_attributes(
            client: an_instance_of(Octokit::Client).and(
              have_attributes(
                options[:client].merge(auto_paginate: true)
              )
            ),
            repository: options[:repository],
            labels: described_class::DEFAULT_LABELS,
            title_rendering: an_instance_of(FlakyTestTracker::Rendering).and(
              have_attributes(
                template: described_class::DEFAULT_TITLE_TEMPLATE
              )
            ),
            body_rendering: an_instance_of(FlakyTestTracker::Rendering).and(
              have_attributes(
                template: described_class::DEFAULT_BODY_TEMPLATE
              )
            ),
            serializer: an_instance_of(FlakyTestTracker::Serializers::TestHTMLSerializer)
          )
        )
      end
    end
  end

  describe "#all" do
    let(:test) { build(:test) }
    let(:issue) { build(:github_issue, id: test.id, html_url: test.url) }

    before do
      allow(client).to receive(:list_issues).and_return([issue])
      allow(serializer).to receive(:deserialize).and_return(test)
    end

    it "fetches the GitHub issues" do
      subject.all

      expect(client).to have_received(:list_issues).with(
        repository,
        { state: :open, labels: labels.join(",") }
      )
    end

    it "deserializes Test from issue body" do
      subject.all

      expect(serializer).to have_received(:deserialize).with(issue.body)
    end

    context "when issue is impossible to deserialize" do
      before do
        allow(serializer).to receive(:deserialize).and_raise(FlakyTestTracker::Error::DeserializeError)
      end

      it "returns empty" do
        expect(subject.all).to be_empty
      end
    end

    it "returns Test list" do
      expect(subject.all).to contain_exactly(test)
    end
  end

  describe "#find" do
    let(:test) { build(:test) }
    let(:id) { test.id }
    let(:issue) { build(:github_issue, id: test.id, html_url: test.url) }

    before do
      allow(client).to receive(:issue).and_return(issue)
      allow(serializer).to receive(:deserialize).and_return(test)
    end

    it "fetches the issue" do
      subject.find(id)

      expect(client).to have_received(:issue).with(
        repository,
        id
      )
    end

    it "deserializes Test from issue body" do
      subject.find(id)

      expect(serializer).to have_received(:deserialize).with(issue.body)
    end

    it "returns Test list" do
      expect(subject.find(id)).to eq(test)
    end
  end

  describe "#create" do
    let(:test_html) { "<!-- html -->" }
    let(:test_input) { build(:test_input) }
    let(:test) { build(:test) }
    let(:issue) { build(:github_issue, id: test.id, html_url: test.url) }

    before do
      allow(client).to receive(:create_issue).and_return(issue)
      allow(serializer).to receive(:serialize).and_return(test_html)
      allow(serializer).to receive(:deserialize).and_return(test)
    end

    it "renders title" do
      subject.create(test_input)

      expect(title_rendering).to have_received(:output).with(
        test: an_instance_of(FlakyTestTracker::Test).and(
          have_attributes(
            test_input.serializable_hash
          )
        )
      )
    end

    it "renders body" do
      subject.create(test_input)

      expect(body_rendering).to have_received(:output).with(
        test: an_instance_of(FlakyTestTracker::Test).and(
          have_attributes(
            test_input.serializable_hash
          )
        )
      )
    end

    it "creates GitHub issue" do
      subject.create(test_input)

      expected_title = title_rendering.output(test: test)
      expected_body = [
        test_html,
        body_rendering.output(test: test)
      ].join("\n")

      expect(client).to have_received(:create_issue).with(
        repository,
        expected_title,
        expected_body,
        { labels: labels.join(",") }
      )
    end

    it "deserializes Test from issue body" do
      subject.create(test_input)

      expect(serializer).to have_received(:deserialize).with(issue.body)
    end

    it "returns Test" do
      expect(subject.create(test_input)).to eq(test)
    end
  end

  describe "#update" do
    let(:test_html) { "<!-- html -->" }
    let(:test) { build(:test) }
    let(:id) { test.id }
    let(:test_input) { build(:test_input) }
    let(:issue) { build(:github_issue, id: test.id, html_url: test.url) }

    before do
      allow(client).to receive(:update_issue).and_return(issue)
      allow(serializer).to receive(:serialize).and_return(test_html)
      allow(serializer).to receive(:deserialize).and_return(test)
    end

    it "renders title" do
      subject.update(id, test_input)

      expect(title_rendering).to have_received(:output).with(
        test: an_instance_of(FlakyTestTracker::Test).and(
          have_attributes(
            test_input.serializable_hash
          )
        )
      )
    end

    it "renders body" do
      subject.update(id, test_input)

      expect(body_rendering).to have_received(:output).with(
        test: an_instance_of(FlakyTestTracker::Test).and(
          have_attributes(
            test_input.serializable_hash
          )
        )
      )
    end

    it "updates GitHub issue" do
      subject.update(id, test_input)

      expected_title = title_rendering.output(test: test)
      expected_body = [
        test_html,
        body_rendering.output(test: test)
      ].join("\n")

      expect(client).to have_received(:update_issue).with(
        repository,
        id,
        expected_title,
        expected_body,
        { labels: labels }
      )
    end

    it "deserializes Test from issue body" do
      subject.update(id, test_input)

      expect(serializer).to have_received(:deserialize).with(issue.body)
    end

    it "returns Test" do
      expect(subject.update(id, test_input)).to eq(test)
    end
  end

  describe "#delete" do
    let(:test) { build(:test) }
    let(:id) { test.id }
    let(:issue) { build(:github_issue, id: test.id, html_url: test.url) }

    before do
      allow(client).to receive(:close_issue).and_return(issue)
      allow(serializer).to receive(:deserialize).and_return(test)
    end

    it "closes GitHub issue" do
      subject.delete(id)

      expect(client).to have_received(:close_issue).with(
        repository,
        id
      )
    end

    it "deserializes Test from issue body" do
      subject.delete(id)

      expect(serializer).to have_received(:deserialize).with(issue.body)
    end

    it "returns Test" do
      expect(subject.delete(id)).to eq(test)
    end
  end
end
