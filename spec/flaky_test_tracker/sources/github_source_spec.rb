# frozen_string_literal: true

RSpec.describe FlakyTestTracker::GitHubSource do
  subject { described_class.new }

  let(:options) do
    {
      host: "mygithub.com",
      repository: "foo/bar",
      commit: "ed4ea5437c628f5014d8ebaf00313eede64c6690"
    }
  end

  describe "#configure" do
    it "sets attributes" do
      subject.configure(options)

      expect(subject).to have_attributes(
        host: options[:host],
        repository: options[:repository],
        commit: options[:commit]
      )
    end

    context "with only required options" do
      let(:options) do
        {
          repository: "foo/bar",
          commit: "ed4ea5437c628f5014d8ebaf00313eede64c6690"
        }
      end

      it "sets attributes using default values" do
        subject.configure(options)

        expect(subject).to have_attributes(
          host: "github.com",
          repository: options[:repository],
          commit: options[:commit]
        )
      end
    end

    describe "#file_source_location_uri" do
      let(:file_path) { "foo/bar.rb" }
      let(:line_number) { 12 }

      before do
        subject.configure(options)
      end

      it "returns the source URI for file" do
        uri = subject.file_source_location_uri(file_path: file_path, line_number: line_number)

        expect(uri).to be_an URI
        expect(uri.to_s).to eq "https://#{options[:host]}/#{options[:repository]}/blob/#{options[:commit]}/#{file_path}#L#{line_number}"
      end
    end

    describe "#source_location_uri" do
      before do
        subject.configure(options)
      end

      it "returns the source URI" do
        uri = subject.source_location_uri

        expect(uri).to be_an URI
        expect(uri.to_s).to eq "https://#{options[:host]}/#{options[:repository]}/tree/#{options[:commit]}"
      end
    end
  end
end
