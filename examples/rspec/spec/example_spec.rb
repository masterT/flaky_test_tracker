# frozen_string_literal: true

RSpec.describe "Example" do
  it "fails" do
    expect(false).to eq true
  end

  it "is flaky" do
    expect([true, false].sample).to eq true
  end

  it "passes" do
    expect(true).to eq true
  end
end
