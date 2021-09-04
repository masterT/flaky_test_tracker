# FlakyTestTracker

> **:warning: Work in progress**

[![Build](https://github.com/masterT/flaky_test_tracker/actions/workflows/build.yml/badge.svg)](https://github.com/masterT/flaky_test_tracker/actions/workflows/build.yml)

FlakyTestTracker is an agnostic testing framework and very customizable tool that [tracks](#track) and [resolves](#resolve) flaky tests (i.e. those which fail non-deterministically) in your project.

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
  config.reporters = []
  config.context = {
    ci_build_id: ENV['CI_BUILD_ID'],
    ci_build_url: ENV['CI_BUILD_URL']
  }
  config.verbose = true
  config.pretend = false
end
```

#### Storage

The storage is responsible of the test persistence.

You can use configure the storage by specifing the type, class or class name of the storage along with the options. The `storage_options` will be passed the storage class method `::build` as keyword arguments using `**`.

```ruby
FlakyTestTracker.configure do |config|
  config.storage_type = :github_issue
  # or `config.storage_class = FlakyTestStorage::Storage::GitHubStorage`
  # or `config.storage_class_name = "FlakyTestStorage::Storage::GitHubStorage"`
  config.storage_options = {}
end
```

Alternativly you can also specify the storage instance directly.

```ruby
FlakyTestTracker.configure do |config|
  config.storage = FlakyTestStorage::Storage::GitHubStorage.build(**options)
end
```

#### Source

The source represents the current source code version on which tests are executed. It is used to resolves a test file location.

You can use configure the source by specifing the type, class or class name of the source along with the options. The `source_options` will be passed the source class method `::build` as keyword arguments using `**`.

```ruby
FlakyTestTracker.configure do |config|
  config.source_type = :github
  # or `config.source_class = FlakyTestStorage::Source::GitHubSource`
  # or `config.source_class_name = "FlakyTestStorage::Source::GitHubSource"`
  config.source_options = {}
end
```

Alternativly you can also specify the source instance directly.

```ruby
FlakyTestTracker.configure do |config|
  config.source = FlakyTestStorage::Source::GitHubSource.build(**options)
end
```

### Reports

You can create reporters to report tracked test(s) and resolved test(s). This can be used to alert you team on your prefered communication channel (email, Slack, Discord, etc.).

You can use configure the reporters by specifing the class or class name of the reporters. The method `::build` will be called on the each class to initialize the reporter.

```ruby
FlakyTestTracker.configure do |config|
  config.reporters_classes = [MyReporter]
  # or `config.reporters_classes = ["MyReporter"]`
end
```

Alternativly you can also specify the storage instance directly.

```ruby
FlakyTestTracker.configure do |config|
  config.reporters = [MyReporter.build]
end
```

The [tracker](#tracker) calls every reporter with:

- `tracked_test(test:, source:, context:)` - For each test tracked
- `tracked_tests(tests:, source:, context:)` - For all tests tracked

The [resolver](#resolver) calls every reporter with:

- `resolved_test(test:)` - For each test resolved
- `resolved_tests(tests:)` - For all tests resolved

The create your reporter create a class with a `::build` method and inherit your class with `FlakyTestTracker::Reporter::BaseReporter`. Then override the methods you need.

```ruby
class MyReporter < FlakyTestTracker::Reporter::BaseReporter
  def self.build
    new
  end

  # @param tests [Test]
  # @param source [#file_source_location_uri, #source_uri]
  # @param context [Hash]
  def tracked_test(test:, source:, context:)
    # ...
  end

  # @param tests [Array<Test>]
  # @param source [#file_source_location_uri, #source_uri]
  # @param context [Hash]
  def tracked_tests(tests:, source:, context:)
    # ...
  end

  # @param test [Test]
  def resolved_test(test:)
    # ...
  end

  # @param tests [Array<Test>]
  def resolved_tests(tests:)
    # ...
  end
end
```

#### Context

You can set a custom context that will be passed to your reporters for the methods `tracked_test` and `tracked_tests`. This is useful to identify the CI build in which the tests failed.

```ruby
FlakyTestTracker.configure do |config|
  config.context = {}
end
```

#### Verbose

When set to `true`, the report `FlakyTestTracker::Reporter::STDOUTReporter` will be added to the configured [reporters](reporters).

It will print verbose message in the `STDOUT`.

```ruby
FlakyTestTracker.configure do |config|
  config.verbose = true
end
```

Output example:

```
[FlakyTestTracker] 1 test(s) tracked
[FlakyTestTracker] 1 test(s) resolved
```

#### Pretend

When set to `true` the [tracker](#tracker) and [resolver](#resolver) will not make changes on the storage. This is usefull to test your configuration setup.

```ruby
FlakyTestTracker.configure do |config|
  config.pretend = true
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
