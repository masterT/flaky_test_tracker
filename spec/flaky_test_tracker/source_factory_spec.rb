# frozen_string_literal: true

RSpec.describe FlakyTestTracker::SourceFactory do
  describe "::configure" do
    context "with github type" do
      let(:type) { :github }
      let(:options) do
        {
          host: "mygithub.com",
          repository: "foo/bar",
          commit: "ed4ea5437c628f5014d8ebaf00313eede64c6690"
        }
      end

      it "returns an instance of GitHubSource" do
        expect(described_class.configure(type: type, options: options)).to be_a(FlakyTestTracker::GitHubSource)
      end
    end

    context "with unkown type" do
      let(:type) { :unkown }
      let(:options) { {} }

      it "raise an ArgumentError" do
        expect { described_class.configure(type: type, options: options) }.to raise_error(ArgumentError, /type/)
      end
    end
  end
end
