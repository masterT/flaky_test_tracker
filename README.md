# FlakyTestTracker

> **:warning: Work in progress**

[![Build](https://github.com/masterT/flaky_test_tracker/actions/workflows/build.yml/badge.svg)](https://github.com/masterT/flaky_test_tracker/actions/workflows/build.yml)

FlakyTestTracker is an automatic flaky test tracking system. It is testing framework agnostic and very customizable.

Features:
- automatically [track](#track) failing tests
- automatically [resolve](#resolve) tracked failing tests

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

The documentation is available online on [rubydoc.info](https://rubydoc.info/github/masterT/flaky_test_tracker).

## Usage

### Track

You can automatically track failing tests on the configured [storage](#storage) for any testing framework, as long as it can provide a unique _reference_ to identify the test.

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

Persists the test on the configured storage.

When test attributes has a `reference` matching a test persisted in the configured storage, the test's `number_occurrences` attribute will be incremented and the test will be updated with the test attributes. Otherwise, a test will be created with the test attributes and `number_occurrences` equals to `1`.

```ruby
FlakyTestTracker.tracker.track
```

Reset the test attributes internal queue:

```ruby
FlakyTestTracker.tracker.clear
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

You can automatically resolve previously tracked failing tests on the configured [storage](#storage).

The `resolve` method calls the block with each tracked test and resolves those for which the block returns a truthy value.

The resolved test are deleted from the configured [storage](#storage).

```ruby
FlakyTestTracker.resolver.resolve do |test|
  # return truthy value to resolve the tracked test passed to block.
end
```

#### Examples

Resolve tests with the last failing occurrence that occurred 14 days ago.

```ruby
DAY_IN_SECOND = 86_400
FlakyTestTracker.resolver.resolve do |test|
  test.finished_at < Time.now - 14 * DAY_IN_SECOND
end
```

It is useful to periodically resolve tests, this can be done using a [Rake](https://rubygems.org/gems/rake) task.

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

### Configuration

The configuration is kept in the `FlakyTestTracker` module and is used to initialize the module [tracked](#track) and [resolver](#resolve) instances.

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
  config.reporter = []
  config.context = {
    ci_build_id: ENV['CI_BUILD_ID'],
    ci_build_url: ENV['CI_BUILD_URL']
  }
  config.verbose = true
  config.pretend = false
end
```

You can access the configuration instance with the `::configuration` method.

```ruby
FlakyTestTracker.configuration
# => #<FlakyTestTracker::Configuration:0x00 ...>
```

#### Storage

The storage is responsible to persist tests.

You can use configure the storage by specifying the type, class, or class name of the store along with the options. The `storage_options` will be passed the storage class method `::build` as keyword arguments using `**`.

```ruby
FlakyTestTracker.configure do |config|
  config.storage_type = :github_issue
  # or `config.storage_class = FlakyTestTracker::Storage::GitHubIssueStorage`
  # or `config.storage_class_name = "FlakyTestTracker::Storage::GitHubIssueStorage"`
  config.storage_options = {}
end
```

Alternatively, you can also specify the storage instance directly.

```ruby
FlakyTestTracker.configure do |config|
  config.storage = FlakyTestTracker::Storage::GitHubIssueStorage.build(**options)
end
```

You can access the configured storage through the  method `#storage` of the `configuration` instance.

```ruby
FlakyTestTracker.configuration.storage
# => #<FlakyTestTracker::Storage::GitHubIssueStorage:0x00 ...>
```

##### Storages

|Storage Type|Storage Class|Documentation|
|---|---|---|
|`:github_issue`|`FlakyTestTracker::Storage::GitHubIssueStorage`|...|

##### Custom Storage

You can use a custom storage, the storage class will need to have to the following interface:

```ruby
class MyStorage
  def self.build(**options)
    new(**options)
  end

  def initialize(**options)
    # ...
  end

  # @return [Array<Test>]
  def all
    # ...
  end

  # @param [TestInput] test_input
  # @return [Test]
  def create(test_input)
    # ...
  end

  # @param [String] id
  # @param [TestInput] test_input
  # @return [Test]
  def update(id, test_input)
    # ...
  end

  # @return [Test]
  def delete(id)
    # ...
  end
end
```

#### Source

The source represents the current source code version on which tests are executed. It is used to resolves a test file location.

You can use configure the source by specifying the type, class, or class name, along with the options. The `source_options` will be passed the source class method `::build` as keyword arguments using `**`.

```ruby
FlakyTestTracker.configure do |config|
  config.source_type = :github
  # or `config.source_class = FlakyTestTracker::Source::GitHubSource`
  # or `config.source_class_name = "FlakyTestTracker::Source::GitHubSource"`
  config.source_options = {}
end
```

Alternatively, you can also specify the source instance directly.

```ruby
FlakyTestTracker.configure do |config|
  config.source = FlakyTestTracker::Source::GitHubSource.build(**options)
end
```

You can access the configured source through the  method `#source` of the `configuration` instance.

```ruby
FlakyTestTracker.configuration.source
# => #<FlakyTestTracker::Source::GitHubSource:0x00 ...>
```

##### Sources

|Source Type|Source Class|Documentation|
|---|---|---|
|`:github`|`FlakyTestTracker::Source::GitHubSource`|...|

##### Custom Source

You can use a custom source, the source class will need to have to the following interface:

```ruby
class MyStorage
  def self.build(**options)
    new(**options)
  end

  def initialize(**options)
    # ...
  end

  # @param file_path [String]
  # @param line_number [Integer]
  # @return [URI]
  def file_source_location_uri(file_path:, line_number:)
    # ...
  end

  # @return [URI]
  def source_uri
    # ...
  end
end
```

#### Reporter

The reporter can be used to alert your team on your preferred communication channel (email, Slack, Discord, etc.).

The [tracker](#tracker) will call the reporter `#tracked_tests` method with all the tests tracked, the [source](#source), and the [context](#context).

The [resolver](#resolver) will calls the reporter `#resolved_tests` method with all the tests resolved.

You can configure the reporter by specifying the class, or class name, along with the options. The `reporter_options` will be passed the reporter class method `::build` as keyword arguments using `**`.

```ruby
FlakyTestTracker.configure do |config|
  config.reporters_class = MyReporter
  # or `config.reporters_class = "MyReporter"`
  config.reporter_options = {}
end
```

Alternatively, you can also specify the storage instance directly.

```ruby
FlakyTestTracker.configure do |config|
  config.reporters = MyReporter.build(**options)
end
```

You can access the configured reporter through the  method `#reporter` of the `configuration` instance.

```ruby
FlakyTestTracker.configuration.reporter
# => #<MyReporter:0x00 ...>
```

##### Reporters

|Reporter Class|Documentation|
|---|---|
|`FlakyTestTracker::Reporter::CollectionReporter`|...|

##### Custom Reporter

You can use a custom reporter. The reporter class will need to respect the following interface:

```ruby
class MyReporter
  def self.build(**options)
    new(**options)
  end

  def initialize(**options)
    # ...
  end

  # @param tests [Array<Test>]
  # @param source [#file_source_location_uri, #source_uri]
  # @param context [Hash]
  def tracked_tests(tests:, source:, context:)
    # ...
  end

  # @param tests [Array<Test>]
  def resolved_tests(tests:)
    # ...
  end
end
```

If you inherit from `FlakyTestTracker::Reporter::BaseReporter`, you will only need to create the `::build` and override the methods you need.

```ruby
class MyReporter < FlakyTestTracker::Reporter::BaseReporter
  def self.build(**options)
    new(**options)
  end

  def initialize(**options)
    # ...
  end
end
```

#### Context

You can set a custom context that will be passed to your reporter `#tracked_tests` method. This is useful to identify the CI build in which the tests failed.

```ruby
FlakyTestTracker.configure do |config|
  config.context = {}
end
```

You can access the configured context through the  method `#context` of the `configuration` instance.

```ruby
FlakyTestTracker.configuration.context
# => {}
```

#### Verbose

When set to `true`, verbose messages will be print in the `STDOUT`.

```ruby
FlakyTestTracker.configure do |config|
  config.verbose = true
end
```

You can access the configured verbose option through the  method `#verbose` of the `configuration` instance.

```ruby
FlakyTestTracker.configuration.verbose
# => true
```

#### Pretend

When set to `true` the [tracker](#tracker) and [resolver](#resolver) will not make changes on the configured [storage](#storage). This is useful to test your configuration setup.

```ruby
FlakyTestTracker.configure do |config|
  config.pretend = true
end
```

You can access the configured pretend option through the  method `#pretend` of the `configuration` instance.

```ruby
FlakyTestTracker.configuration.pretend
# => true
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reporter and pull requests are welcome on GitHub at https://github.com/masterT/flaky_test_tracker. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/masterT/flaky_test_tracker/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the FlakyTestTracker project's codebases, issue trackers, chat rooms, and mailing lists is expected to follow the [code of conduct](https://github.com/masterT/flaky_test_tracker/blob/main/CODE_OF_CONDUCT.md).
