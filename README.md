# FlakyTestTracker

> **:warning: Work in progress**

[![Build](https://github.com/masterT/flaky_test_tracker/actions/workflows/build.yml/badge.svg)](https://github.com/masterT/flaky_test_tracker/actions/workflows/build.yml)

Track flaky tests (i.e. those which fail non-deterministically) to help you fix them.

Storage:
- GitHub Issue

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'flaky_test_tracker'
```

And then execute:

```
$ bundle install
```

Or install it yourself as:

```
$ gem install flaky_test_tracker
```

## Usage

### Storage

...

### Track flaky tests

You should track flaky tests on a stable code base.

#### RSpec

Example using [RSpec](https://rubygems.org/gems/rspec).

```ruby
# frozen_string_literal: true

require "flaky_test_tracker"

stable_branches = ["develop", "main"]
if ENV["CI"] == "true" && stable_branches.include?(ENV["CI_BRANCH"])
  tracker = FlakyTestTracker.tracker(
    verbose: true,
    source: {
      type: :github,
      options: {
        repository: "github-username/repository-name",
        commit: ENV["CI_COMMIT"],
        branch: ENV["CI_BRANCH"]
      }
    },
    reporters: [],
    storage: {
      type: :github_issue,
      options: {
        client: {
          access_token: ENV["GITHUB_ACCESS_TOKEN"]
        },
        repository: "github-username/repository-name",
        labels: ["flaky test"]
      }
    }
  )

  RSpec.configure do |config|
    config.before(:suite) do
      tracker.clear
    end

    config.after do |example|
      if example.exception
        tracker.add(
          reference: example.id,
          description: example.full_description,
          exception: example.exception.to_s.gsub(/\x1b\[[0-9;]*[a-zA-Z]/, ""), # Remove ANSI formatting.
          file_path: example.metadata[:file_path],
          line_number: example.metadata[:line_number]
        )
      end
    end

    config.after(:suite) do
      tracker.track
    end
  end
end
```

### Resolve flaky tests

Once you fixed the flaky test, you can manually delete them from the storage or you can use the `FalkyTestTracker::Resolver` to do it automatically, e.g: using a _Rake_ taks that run periodically.

```ruby
# frozen_string_literal: true

require "flaky_test_tracker"

resolver = FlakyTestTracker.resolver(
  verbose: true,
  reporters: [],
  storage: {
    type: :github_issue,
    options: {
      client: {
        access_token: ENV["GITHUB_ACCESS_TOKEN"]
      },
      repository: "github-username/repository-name",
      labels: ["flaky test"]
    }
  }
)
```

By default it will delete flaky tests that did not fail in the last 40 days.

```ruby
resolver.resolve
```

You can change the duration, with the option `duration_period_without_failure`.

```ruby
DAY_IN_SECOND = 86_400

resolver = FlakyTestTracker.resolver(
  duration_period_without_failure: 10 * DAY_IN_SECOND,
  # ...
)

resolver.resolve
```

You can also select the flaky test with your how logic by passing a block which returns if the test should be resolved.

```ruby
resolver.resolve do |test|
  # ...
end
```




## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/masterT/flaky_test_tracker. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/masterT/flaky_test_tracker/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the FlakyTestTracker project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/masterT/flaky_test_tracker/blob/main/CODE_OF_CONDUCT.md).
