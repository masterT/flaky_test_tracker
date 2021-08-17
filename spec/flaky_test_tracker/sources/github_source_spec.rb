# frozen_string_literal: true

require "uri"

RSpec.describe FlakyTestTracker::GitHubSource do
  subject do
    described_class.new(
      host: host,
      repository: repository,
      commit: commit,
      branch: branch
    )
  end

  let(:host) { "mygithub.com" }
  let(:repository) { "foo/bar" }
  let(:commit) { "0612bcf5b16a1ec368ef4ebb92d6be2f7040260b" }
  let(:branch) { "main" }

  describe "::new" do
    it "sets attributes" do
      expect(
        described_class.new(
          host: host,
          repository: repository,
          commit: commit,
          branch: branch
        )
      ).to have_attributes(
        host: host,
        repository: repository,
        commit: commit,
        branch: branch
      )
    end

    context "with only required attributes" do
      it "sets attributes using default values" do
        expect(
          described_class.new(
            repository: repository,
            commit: commit,
            branch: branch
          )
        ).to have_attributes(
          host: "github.com",
          repository: repository,
          commit: commit,
          branch: branch
        )
      end
    end

    describe "#file_source_location_uri" do
      let(:file_path) { "foo/bar.rb" }
      let(:line_number) { 12 }

      it "returns the source URI for file" do
        uri = subject.file_source_location_uri(file_path: file_path, line_number: line_number)

        expect(uri).to be_an URI
        expect(uri.to_s).to eq "https://#{host}/#{repository}/blob/#{commit}/#{file_path}#L#{line_number}"
      end
    end

    describe "#source_uri" do
      it "returns the source URI" do
        uri = subject.source_uri

        expect(uri).to be_an URI
        expect(uri.to_s).to eq "https://#{host}/#{repository}/tree/#{commit}"
      end
    end
  end
end
