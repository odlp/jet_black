# JetBlack

[![CircleCI](https://circleci.com/gh/odlp/jet_black.svg?style=svg)](https://circleci.com/gh/odlp/jet_black) [![Coverage Status](https://coveralls.io/repos/github/odlp/jet_black/badge.svg?branch=master)](https://coveralls.io/github/odlp/jet_black?branch=master)

A black-box testing utility for command line tools and gems. Written in Ruby,
with [RSpec] in mind. Features:

[RSpec]: http://rspec.info/

- Each session takes place within a unique temporary directory, outside the project
- Synchronously [run commands](#running-commands) then write assertions on:
  - The `stdout` / `stderr` content
  - The exit status of the process
- Manipulate files in the temporary directory:
  - [Create files](#file-manipulation)
  - [Create executable files](#file-manipulation)
  - [Append content to files](#file-manipulation)
  - [Copy fixture files](#copying-fixture-files) from your project
- Modify the environment without changing the parent test process:
  - [Override environment variables](#environment-variable-overrides)
  - [Escape the current Bundler context](#clean-bundler-environment)
  - [Adjust `$PATH`](#path-prefix) to include your executable / Subject Under Test
- [RSpec matchers](#rspec-matchers) (optional)

The temporary directory is discarded after each spec. This means you can write &
modify files and run commands (like `git init`) without worrying about tidying
up after or impacting your actual project.

## Setup

```ruby
group :test do
  gem "jet_black"
end
```

### RSpec setup

If you're using RSpec, you can load matchers with the following require
(optional):

```ruby
# spec/spec_helper.rb

require "jet_black/rspec"
```

Any specs you write in the `spec/black_box` folder will then have an inferred
`:black_box` meta type, and the matchers will be available in those examples.

#### Manual RSpec setup

Alternatively you can manually include the matchers:

```ruby
# spec/cli/example_spec.rb

require "jet_black"
require "jet_black/rspec/matchers"

RSpec.describe "my command line tool" do
  include JetBlack::RSpec::Matchers
end
```

## Usage

### Running commands

```ruby
require "jet_black"

session = JetBlack::Session.new
result = session.run("echo foo")

result.stdout # => "foo"
result.stderr # => ""
result.exit_status # => 0
```

Providing `stdin` data:

```ruby
session = JetBlack::Session.new
session.run("./hello-world", stdin: "Alice")
```

### File manipulation

```ruby
session = JetBlack::Session.new

session.create_file "file.txt", <<~TXT
  The quick brown fox
  jumps over the lazy dog
TXT

session.create_executable "hello-world.sh", <<~SH
  #!/bin/sh
  echo "Hello world"
SH

session.append_to_file "file.txt", <<~TXT
  shiny
  new
  lines
TXT

# Subdirectories are created for you:
session.create_file "deeper/underground/jamiroquai.txt", <<~TXT
  I'm going deeper underground, hey ha
  There's too much panic in this town
TXT
```

### Copying fixture files

It's ideal to create pertinent files inline within a spec, to provide context
for the reader, but sometimes it's better to copy across a large or
non-human-readable file.

1.    Create a fixture directory in your project, such as `spec/fixtures/black_box`.

2.    Configure the fixture path in `spec/support/jet_black.rb`:

      ```ruby
      require "jet_black"

      JetBlack.configure do |config|
        config.fixture_directory = File.expand_path("../fixtures/black_box", __dir__)
      end
      ```

3.    Copy fixtures across into a session's temporary directory:

      ```ruby
      session = JetBlack::Session.new
      session.copy_fixture("src-config.json", "config.json")

      # Destination subdirectories are created for you:
      session.copy_fixture("src-config.json", "config/config.json")
      ```

### Environment variable overrides

```ruby
session = JetBlack::Session.new
result = subject.run("echo $FOO", env: { FOO: "bar" })

result.stdout # => "bar"
```

Provide a `nil` value to unset an environment variable.

### Clean Bundler environment

If your project's test suite is invoked with Bundler (e.g. `bundle exec rspec`)
but you want to run commands like `bundle install` and `bundle exec` with a
different Gemfile in a given spec, you can configure the session or individual
commands to run with a clean Bundler environment.

```ruby
# Per command
session = JetBlack::Session.new
subject.run("bundle install", options: { clean_bundler_env: true })

# Per session
session = JetBlack::Session.new(options: { clean_bundler_env: true })
subject.run("bundle install")
subject.run("bundle exec rake")
```

### `$PATH` prefix

Given the root of your project contains a `bin` directory containing
`my_awesome_bin`.

Configure the `path_prefix` to the directory containing with your executable(s):

```ruby
# spec/support/jet_black.rb

require "jet_black"

JetBlack.configure do |config|
  config.path_prefix = File.expand_path("../../bin", __dir__)
end
```

Then the `$PATH` of each session will include the configured directory, and your
executable should be invokable:

```ruby
JetBlack::Session.new.run("my_awesome_bin")
```

### RSpec matchers

Given the [RSpec setup](#rspec-setup) is configured, you'll have access to the
following matchers:

- `have_stdout` which accepts a string or regular expression
- `have_stderr` which accepts a string or regular expression
- `have_no_stdout` which asserts the `stdout` is empty
- `have_no_stderr` which asserts the `stderr` is empty

And the following predicate matchers:

- `be_a_success` / `be_success` asserts the exit status was zero
- `be_a_failure` / `be_failure` asserts the exit status was not zero

#### Example assertions

```ruby
# spec/black_box/cli_spec.rb

RSpec.describe "my command line tool" do
  let(:session) { JetBlack::Session.new }

  it "does the work" do
    expect(session.run("my_tool --good")).
      to be_a_success.and have_stdout(/It worked/)
  end

  it "explodes with incorrect arguments" do
    expect(session.run("my_tool --bad")).
      to be_a_failure.and have_stderr("Oh no!")
  end
end
```

However these assertions can be made with built-in matchers too:

```ruby
RSpec.describe "my command line tool" do
  let(:session) { JetBlack::Session.new }

  it "does the work" do
    result = session.run("my_tool --good")

    expect(result.stdout).to match(/It worked/)
    expect(result.exit_status).to eq 0
  end

  it "explodes with incorrect arguments" do
    result = session.run("my_tool --bad")

    expect(result.stderr).to match("Oh no!")
    expect(result.exit_status).to eq 1
  end
end
```
