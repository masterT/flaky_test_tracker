# FlakyTestTracker

> **:warning: Work in progress**

[![Build](https://github.com/masterT/flaky_test_tracker/actions/workflows/build.yml/badge.svg)](https://github.com/masterT/flaky_test_tracker/actions/workflows/build.yml)

FlakyTestTracker is a Ruby gem library to help you and your team manage flaky test (i.e. those which fail non-deterministically) in your project. It is agnostic of the testing framework and very customizable.

It can persist tests using different [storages](#storage).

It can [track](#track) and [report](#report) test when they run on your _CI_.

It can automatically [resolve](#resolve) and [report](#report) tracked test when their are not failing anymore.

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

- [Configuration](#configuration)
- [Storage](#storage)
  - [GitHub Issue Storage](#github-issue-storage)
  - [Custom Storage](#custom-storage)
- [Source](#source)
  - [GitHub Source](#github-source)
  - [Custom Source](#custom-source)
- [Track](#track)
  - [Examples](#examples)
- [Resolve](#resolve)
- [Report](#report)
- [Context](#context)

### Configuration

```ruby
FlakyTestTracker.configure do |config|
  config.storage_type = :github_issue
  config.storage_options = {
    client: {
      access_token: ENV['GITHUB_ACCESS_TOKEN']
    },
    repository: 'masterT/flaky_test_tracker',
    labels: ['flaky test']
  }
  config.source_type = :github
  config.source_options = {
    repository: "github-username/repository-name",
    commit: ENV["CI_COMMIT"],
    branch: ENV["CI_BRANCH"]
  }
  config.context = {
    ci_build_id: ENV['CI_BUILD_ID'],
    ci_build_url: ENV['CI_BUILD_URL']
  }
  config.reporters = [MyReporter.new]
  config.verbose = true
end
```

### Storage

The storage persistes test.

- [GitHub Issue Storage](#github-issue-storage)
- [Custom Storage](#custom-storage)

#### GitHub Issue Storage

Store failing test on GitHub Issue of a GitHub repository. It will open GitHub Issue using with the `labels` on the `repository` using the GitHub `access_token`.

[Create a new GitHub access token](https://github.com/settings/tokens/new), it must have the "repo" scope.

You can also provide a `title_template` and `body_template` to render GitHub Issue title and body. The template will be parsed as `ERB` and will be bind with the `test` variable representing a `FlakyTestTracker::Test` instance.

```ruby
FlakyTestTracker.configure do |config|
  config.storage_type = :github_issue
  config.storage_options = {
    client: {
      access_token: ENV['GITHUB_ACCESS_TOKEN']
    },
    repository: 'masterT/flaky_test_tracker',
    labels: ['flaky test'],
    title_template: "Flaky test <%= test.reference %>"
    body_template: <<~ERB
      ### Reference
      <%= test.reference %>

      ### Description
      <i><%= test.description %></i>

      ### Exception
      <pre><%= test.exception %></pre>

      ### Failed at
      <%= test.finished_at %>

      ### Number occurrences
      <%= test.number_occurrences %>

      ### Location
      [<%= test.location %>](<%= test.source_location_url %>)
    ERB
  }
end
```

Under the hood the `test` will be [JSON](https://en.wikipedia.org/wiki/JSON) encoded, then [base64](https://en.wikipedia.org/wiki/Base64) encoded and finally placed in an HTML comment tag, which will be prepend to the GitHub Issue body.

#### Custom Storage

You can use your own storage by specifing the class or the class name, and the options. The `storage_options` will be passed the class method `::build`.

```ruby
FlakyTestTracker.configure do |config|
  config.storage_class = MyStorage
  # or `config.storage_class_name = 'MyStorage'`
  config.storage_options = {
    foo: 'bar'
  }
end
```

Alternativly you can also specify the storage instance directly.

```ruby
FlakyTestTracker.configure do |config|
  config.storage = MyStorage.new(foo: 'bar')
end
```

The storage must have to following interface:

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

### Source

The source resolves a test file location. It is used by the `FlakyTestTracker::Tracker` to set the attribute `source_location_url` of the `FlakyTestTracker::TestInput` which is passed to the storage to persiste the test.

- [GitHub Source](#github-source)
- [Custom source](#custom-source)


#### GitHub Source

Resolve file location on a GitHub repository.

```ruby
FlakyTestTracker.configure do |config|
  config.source_type = :github
  config.source_options = {
    host: "github.com",
    repository: "github-username/repository-name",
    commit: ENV["CI_COMMIT"],
    branch: ENV["CI_BRANCH"]
  }
end
```

#### Custom Source

You can add your own source  by specifing the class or the class name, and the options. The `source_options` will be passed the class method `::build`.

```ruby
FlakyTestTracker.configure do |config|
  config.source_class = CustomSource
  # or `config.source_class_name = 'CustomSource'`
  config.source_options = {
    foo: 'bar'
  }
end
```

Alternativly you can also specify the storage instance directly.

```ruby
FlakyTestTracker.configure do |config|
  config.source = CustomSource.new(foo: 'bar')
end
```

The source must have to following interface:

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

Finally persiste the test on the storage:

```ruby
FlakyTestTracker.tracker.track
```

#### Examples

Example with [RSpec](https://rubygems.org/gems/rspec).

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
    puts "Can't track falky tests"
  end
end
```

### Resolve

You can resolve previously tracked test when they are not failing anymore, this will delete tests in the storage.

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

### Report

You can create a reporter to report tracked test(s) and resolved test(s). This can be used to alert you team on your prefered communication channel.

```ruby
class MyReporter < FlakyTestTracker::Reporters::BaseReporter
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

### Context

You can set a custom context that will be passed to your reporters for the methods `tracked_test` and `tracked_tests`. This is useful to identify the CI build in which the tests failed.

Example:

```ruby
FlakyTestTracker.configure do |config|
  config.context = {
    ci_build_id: ENV['CI_BUILD_ID'],
    ci_build_url: ENV['CI_BUILD_URL']
  }
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
