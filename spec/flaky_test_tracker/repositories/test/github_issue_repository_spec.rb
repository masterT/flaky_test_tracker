# frozen_string_literal: true

require "octokit"

RSpec.describe FlakyTestTracker::Repositories::Test::GitHubIssueRepository do
  subject do
    described_class.new(
      client: client,
      repository: repository,
      labels: labels,
      title_rendering: title_rendering,
      body_rendering: body_rendering,
      test_serializer: test_serializer
    )
  end

  let(:client) { instance_double(Octokit::Client) }
  let(:repository) { "foo/bar" }
  let(:labels) { "flaky" }
  let(:title_rendering) { spy("rendering", output: "title") }
  let(:body_rendering) { spy("rendering", output: "body") }
  let(:test_serializer) { spy("test_serializer") }

  describe "#all" do
    let(:test) { build(:test) }
    let(:issue) { build(:github_issue, id: test.id, html_url: test.url) }

    before do
      allow(client).to receive(:list_issues).and_return([issue])
      allow(test_serializer).to receive(:deserialize).and_return(test)
    end

    it "fetches the GitHub issues" do
      subject.all

      expect(client).to have_received(:list_issues).with(
        repository,
        { state: :open, labels: labels }
      )
    end

    it "deserializes Test from issue body" do
      subject.all

      expect(test_serializer).to have_received(:deserialize).with(issue.body)
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
      allow(test_serializer).to receive(:deserialize).and_return(test)
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

      expect(test_serializer).to have_received(:deserialize).with(issue.body)
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
      allow(test_serializer).to receive(:serialize).and_return(test_html)
      allow(test_serializer).to receive(:deserialize).and_return(test)
    end

    it "renders title" do
      subject.create(test_input)

      expect(title_rendering).to have_received(:output).with(
        test: an_instance_of(FlakyTestTracker::Models::Test).and(
          have_attributes(
            test_input.serializable_hash
          )
        )
      )
    end

    it "renders body" do
      subject.create(test_input)

      expect(body_rendering).to have_received(:output).with(
        test: an_instance_of(FlakyTestTracker::Models::Test).and(
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
        { labels: labels }
      )
    end

    it "deserializes Test from issue body" do
      subject.create(test_input)

      expect(test_serializer).to have_received(:deserialize).with(issue.body)
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
      allow(test_serializer).to receive(:serialize).and_return(test_html)
      allow(test_serializer).to receive(:deserialize).and_return(test)
    end

    it "renders title" do
      subject.update(id, test_input)

      expect(title_rendering).to have_received(:output).with(
        test: an_instance_of(FlakyTestTracker::Models::Test).and(
          have_attributes(
            test_input.serializable_hash
          )
        )
      )
    end

    it "renders body" do
      subject.update(id, test_input)

      expect(body_rendering).to have_received(:output).with(
        test: an_instance_of(FlakyTestTracker::Models::Test).and(
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

      expect(test_serializer).to have_received(:deserialize).with(issue.body)
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
      allow(test_serializer).to receive(:deserialize).and_return(test)
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

      expect(test_serializer).to have_received(:deserialize).with(issue.body)
    end

    it "returns Test" do
      expect(subject.delete(id)).to eq(test)
    end
  end
end
