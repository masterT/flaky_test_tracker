# frozen_string_literal: true

RSpec.describe FlakyTestTracker::Storages::GitHubIssueStorage do
  subject { described_class.new }

  let(:client) { instance_double(Octokit::Client) }
  let(:options) do
    {
      client: { access_token: "0612bcf5b16a1ec368ef4ebb92d6be2f7040260b" },
      repository: "foo/bar",
      label: "flaky",
      title_rendering: instance_double(FlakyTestTracker::Rendering::BaseRendering),
      body_rendering: instance_double(FlakyTestTracker::Rendering::BaseRendering)
    }
  end

  before do
    allow(Octokit::Client).to receive(:new).and_return(client)
  end

  describe "#configure" do
    it "configures client" do
      subject.configure(options)

      expect(Octokit::Client).to have_received(:new).with(
        { auto_paginate: true }.merge(
          options[:client]
        )
      )
    end

    it "sets attributes" do
      subject.configure(options)

      expect(subject).to have_attributes(
        client: client,
        repository: options[:repository],
        label: options[:label]
      )
    end
  end

  context "when configured" do
    before do
      subject.configure(options)
    end

    describe "#all" do
      let(:test_occurrence) { build(:test_occurrence) }
      let(:test) { build(:test, occurrences: [test_occurrence]) }
      let(:agent) { Sawyer::Agent.new("https://api.github.com/") }
      let(:issues) do
        [
          Sawyer::Resource.new(
            agent,
            {
              body: test.as_html_comment.to_html
            }
          )
        ]
      end

      before do
        allow(client).to receive(:list_issues).and_return(issues)
      end

      it "fetchs issues" do
        subject.all

        expect(client).to have_received(:list_issues).with(
          options[:repository],
          { state: :open, labels: options[:label] }
        )
      end

      it "returns Test list" do
        pp subject.all
        puts
        pp subject.all.first.occurrences.first

        puts

        pp test_occurrence.serializable_hash
        puts
        expect(subject.all.first.occurrences.first).to have_attributes(test_occurrence.serializable_hash)

        expect(subject.all).to contain_exactly(
          an_instance_of(FlakyTestTracker::Models::Test) & have_attributes(
            # id: test.id,
            reference: test.reference,
            occurrences: a_collection_containing_exactly(
              an_instance_of(FlakyTestTracker::Models::TestOccurrence) & have_attributes(
                test_occurrence.serializable_hash
              )
            )
          )
        )
      end
    end
  end
end


class Storage
  def initialize(engine:, reporter:)
    @engine = engine
    @reporter = reporter
    @tests = nil
  end

  def confine(test_occurence:)
    test = test_by_reference[test_occurence.reference]
    if test
      engine.update(
        id: test.id,
        reference: test.reference,
        occurrences: test.occurrences + [test_occurence]
      )
    else
      engine.create(
        reference: test_occurence.reference,
        occurrences: test_occurence.reference
      )
    end
  end

  def deconfine(id:)
    test = @engine.delete(id: id)
    reporter.on_deconfine(test: test)
    test
    # TODO
  end

  def tests
    @tests ||= engine.all
  end

  def clear
    @tests = nil
  end

  def test_by_reference
    @test_by_reference ||= tests.each_with_object({}) do |test, hash|
      hash[test.reference] = test
    end
  end
end


class DatabaseEngine
  def update(id:, reference:, test_occurrences:)
    test_record = TestRecord.find(id)
    test_record.assign_attributes(reference: reference)
    test_record.test_occurrences = test_occurrences.map do |test_occurrence|
      TestOccurrenceRecord.find_or_create_by!(
        reference: test_occurrence.reference
        # ...
      )
    end
    test_record.save!
    to_model(test_record)
  end

  def create(reference:, test_occurrences:)
    test_record = TestRecord.create!(reference: reference)
    test_record.test_occurrences = test_occurrences.map do |test_occurrence|
      TestOccurrenceRecord.find_or_create_by!(
        reference: test_occurrence.reference
        # ...
      )
    end
    test_record.save!
    to_model(test_record)
  end
end

class TestRepository
  def create(attributes)
    test_record = TestRecord.create!(attributes)
    to_model(test_record)
  end
end

class TestOccurrenceRepository
  def create(attributes)
    test_occurrence_record = TestOccurrenceRecord.create!(attributes)
    to_model(test_occurrence_record)
  end
end

flaky = Flaky.new(
  # configuration
)

flaky.add(
  reference: example.id,
  # ...
)

flaky.confine


class Storage
  def initialize(engine:)
    @engine = engine
    @tests = nil
  end

  def list_tests
  end

  def create_test_occurence(test_occurence_input:)
    test = test_by_reference[test_occurence_input.reference]
    if test
      update(
        id: test.id,
        occurrences: test.occurrences + [TestOccurrence.new()]
      )
      test.occurrences << TestOccurrence.new()
    else
    end
  end

  def delete_test()
  end

  def clear
    @tests = nil
  end

  private

  def tests
    @tests ||= engine.all
  end

  def test_by_reference
    @test_by_reference ||= tests.each_with_object({}) do |test, hash|
      hash[test.reference] = test
    end
  end
end



class Controller
  attr_reader :storage

  def confine(test_occurence)
    test = test_by_reference[test_occurence.reference]
    if test
      UpdateTestAction
        .perform(
          input: UpdateTestInput.new(
            occurences:
          )
        )
        .on_success do |test:|
          test.foo
        end
        .on_failure do |error:|
        end
    else
    end
  end

  private

  def tests
    @tests ||= engine.all
  end

  def test_by_reference
    @test_by_reference ||= tests.each_with_object({}) do |test, hash|
      hash[test.reference] = test
    end
  end
end
