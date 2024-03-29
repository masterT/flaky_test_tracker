# frozen_string_literal: true

require "flaky_test_tracker"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

# Load support files.
Dir[
  File.join(__dir__, "support", "**", "*.rb")
].sort.each { |f| require f }
