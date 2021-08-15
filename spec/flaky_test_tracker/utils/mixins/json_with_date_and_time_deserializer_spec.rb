# frozen_string_literal: true

RSpec.describe FlakyTestTracker::Utils::Mixins::JSONWithDateTimeDeserializer do
  subject { test_class.new }

  let(:test_class) do
    Class.new do
      include FlakyTestTracker::Utils::Mixins::JSONWithDateTimeDeserializer
    end
  end

  describe "#from_json_with_date_and_time" do
    let(:time) { Time.now }
    let(:time_serialized) { time.iso8601(9) }

    let(:date) { Date.today }
    let(:date_serialized) { date.iso8601 }

    let(:json) { JSON.generate(value) }

    context "with Time" do
      let(:value) { time_serialized }

      it "returns value with date and time" do
        expect(subject.from_json_with_date_and_time(json)).to eq(
          time
        )
      end
    end

    context "with Date" do
      let(:value) { date_serialized }

      it "returns value with date and time" do
        expect(subject.from_json_with_date_and_time(json)).to eq(
          date
        )
      end
    end

    context "with nil" do
      let(:value) { nil }

      it "returns value with date and time" do
        expect(subject.from_json_with_date_and_time(json)).to eq(
          nil
        )
      end
    end

    context "with String" do
      let(:value) { "foo" }

      it "returns value with date and time" do
        expect(subject.from_json_with_date_and_time(json)).to eq(
          value
        )
      end
    end

    context "with Integer" do
      let(:value) { 1 }

      it "returns value with date and time" do
        expect(subject.from_json_with_date_and_time(json)).to eq(
          value
        )
      end
    end

    context "with Float" do
      let(:value) { 1.1 }

      it "returns value with date and time" do
        expect(subject.from_json_with_date_and_time(json)).to eq(
          value
        )
      end
    end

    context "with true" do
      let(:value) { true }

      it "returns value with date and time" do
        expect(subject.from_json_with_date_and_time(json)).to eq(
          value
        )
      end
    end

    context "with false" do
      let(:value) { false }

      it "returns value with date and time" do
        expect(subject.from_json_with_date_and_time(json)).to eq(
          value
        )
      end
    end

    context "with Array" do
      let(:value) { [time_serialized, date_serialized, nil, 1, 1.1, true, false, [], {}] }

      it "returns value with date and time" do
        expect(subject.from_json_with_date_and_time(json)).to eq(
          [time, date, nil, 1, 1.1, true, false, [], {}]
        )
      end
    end

    context "with Hash" do
      let(:value) do
        {
          "time" => time_serialized,
          "date" => date_serialized,
          "nil" => nil,
          "integer" => 1,
          "float" => 1.1,
          "true" => true,
          "false" => false,
          "array" => [],
          "hash" => {}
        }
      end

      it "returns value with date and time" do
        expect(subject.from_json_with_date_and_time(json)).to eq(
          {
            "time" => time,
            "date" => date,
            "nil" => nil,
            "integer" => 1,
            "float" => 1.1,
            "true" => true,
            "false" => false,
            "array" => [],
            "hash" => {}
          }
        )
      end
    end
  end
end
