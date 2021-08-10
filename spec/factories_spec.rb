# frozen_string_literal: true

RSpec.describe "FactoryBot factories" do
  it do
    expect { FactoryBot.lint(verbose: true, traits: true) }.not_to raise_error
  end
end
