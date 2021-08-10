# frozen_string_literal: true

require "shoulda-matchers"
require "active_model"

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :active_model
  end
end
