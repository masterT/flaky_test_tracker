# FlakyTestTracker

> **:warning: Work in progress**

[![Build](https://github.com/masterT/flaky_test_tracker/actions/workflows/build.yml/badge.svg)](https://github.com/masterT/flaky_test_tracker/actions/workflows/build.yml)

FlakyTestTracker provides the tool to [track](#track) and [resolve](#resolve) flaky test (i.e. those which fail non-deterministically) in your project. It is agnostic of the testing framework and very customizable.

It supports multiple storage to persiste tests:
- GitHub Issue
- Custom

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

## Documentation

The documentation is available on [rubydoc.info](https://rubydoc.info/github/masterT/flaky_test_tracker).


## Usage

### Configuration

The configuration is kept in the `FlakyTestTracker` module and used to track and resolve tests.

```ruby
FlakyTestTracker.configure do |config|
  config.storage_type = :github_issue
  config.storage_options = {
    client: {
      access_token: ENV['GITHUB_ACCESS_TOKEN']
    },
    repository: 'foo/bar',
    labels: ['flaky test']
  }
  config.source_type = :github
  config.source_options = {
    repository: "foo/bar",
    commit: ENV["CI_COMMIT"],
    branch: ENV["CI_BRANCH"]
  }
  config.context = {
    ci_build_id: ENV['CI_BUILD_ID'],
    ci_build_url: ENV['CI_BUILD_URL']
  }
  config.reporters = []
  config.verbose = true
end
```

### Track

You can track test for any testing framework as long as it can provide a unique _reference_ to identify the test.

Reset the test attributes internal queue:

```ruby
FlakyTestTracker.tracker.clear
```

Add failing test attributes to the internal queue:

```ruby
FlakyTestTracker.tracker.add(
  reference: "./spec/foo_spec.rb[1:2]",
  description: "returns true when foo",
  exception: %{
    expected: true
     got: false
    (compared using ==)
    Diff:
    @@ -1 +1 @@
    -true
    +false
  },
  file_path: "./spec/foo_spec.rb",
  line_number: 8
)
```

Finally persiste the test on the configured storage:

```ruby
FlakyTestTracker.tracker.track
```

#### Examples

Example with [RSpec](https://rubygems.org/gems/rspec) testing framework.

```ruby
RSpec.configure do |config|
  config.before(:suite) do
    FlakyTestTracker.tracker.clear
  end

  config.after do |example|
    if example.exception
      FlakyTestTracker.tracker.add(
        reference: example.id,
        description: example.full_description,
        exception: example.exception.gsub(/\x1b\[[0-9;]*[a-zA-Z]/, ""), # Remove ANSI formatting.
        file_path: example.metadata[:file_path],
        line_number: example.metadata[:line_number]
      )
    end
  end

  config.after(:suite) do
    FlakyTestTracker.tracker.track
  rescue StandardError
    # ...
  end
end
```

### Resolve

You can resolve previously tracked tests, using you custom logic, this will remove the tests in the configued storage.

Example this will only resolve tests with the last failing occurence occured 14 days ago.

```ruby
DAY_IN_SECOND = 86_400
FlakyTestTracker.resolver.resolve do |test|
  test.finished_at < Time.now - 14 * DAY_IN_SECOND
end
```

It is useful to periodically resolve tests, example using a [Rake](https://rubygems.org/gems/rake) task.

```ruby
# frozen_string_literal: true
namesapce :falky_test_tracker do
  desc 'Resolve tests with the last failing occurence tracked 14 days ago'
  task :resolve do
    DAY_IN_SECOND = 86_400
    FlakyTestTracker.resolver.resolve do |test|
      test.finished_at < Time.now - 14 * DAY_IN_SECOND
    end
  end
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
