# frozen_string_literal: true

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

# Load initializers.
Dir[
  File.join(__dir__, "initializers", "**", "*.rb")
].sort.each { |f| require f }
