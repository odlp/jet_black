# JetBlack

[![CircleCI](https://circleci.com/gh/odlp/jet_black.svg?style=svg)](https://circleci.com/gh/odlp/jet_black)

A black-box testing utility for command line tools, written in Ruby. Features:

- Each session is within a unique temporary directory, outside the project
- Synchronously run commands then write assertions on the:
  - `stdout` / `stderr` content
  - exit status of the process
- Convenient manipulate files in the temporary directory:
  - Create files
  - Append content to files
  - Copy fixture files from your project
- Modify the environment without modifying the parent test process:
  - Override environment variables
  - Escape the current Bundler context
  - Adjust `$PATH` to include your executable / Subject Under Test
- RSpec matchers (optional)

The temporary directory is discarded after each spec. This means you can write
& modify files and run commands (like `git init`) without worrying about tidying
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

### File manipulation

```ruby
require "jet_black"

session = JetBlack::Session.new

session.create_file "file.txt", <<~TXT
  The quick brown fox
  jumps over the lazy dog
TXT

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
for the reader, but sometimes a large or non-readable file is best copied
across.

First create a fixture directory in your project, such as
`spec/fixtures/black_box`. Then configure the fixture path in
`spec/support/jet_black.rb`:

```ruby
require "jet_black"

JetBlack.configure do |config|
  config.fixture_directory = File.expand_path("../fixtures/black_box", __dir__)
end
```

Or in `spec/spec_helper.rb` the directory would be resolved as:

```ruby
File.expand_path("fixtures/black_box", __dir__)
```

Now you can copy fixtures across into a session's temporary directory:

```ruby
require "jet_black"

session = JetBlack::Session.new
session.copy_fixture("src-config.json", "config.json")

# Destination subdirectories are created for you:
session.copy_fixture("src-config.json", "config/config.json")
```

### Environment overrides

```ruby
require "jet_black"

session = JetBlack::Session.new
result = subject.run("echo $FOO", env: { FOO: "bar" })

result.stdout # => "bar"
```

### Clean Bundler environment

If the test suite is invoked with Bundler (e.g. `bundle exec rspec`) but you
want to run commands like `bundle install` and `bundle exec` with a different
Gemfile in a given spec, you can configure the session or individual commands to
run with a clean Bundler environment.

```ruby
require "jet_black"

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
  config.path_prefix = File.expand("../../bin", __dir__)
end
```

Then the `$PATH` of each session will include the configured directory, and your
executable should be invokable:

```ruby
require "jet_black"

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
require "jet_black"

RSpec.describe "my command line tool" do
  let(:session) { JetBlack::Session.new }

  it "does the work" do
    expect(session.run("my_tool --good")).
      to be_a_success.and have_stdout(/It worked/)
  end

  it "explodes with incorrect arguments" do
    expect(session.run("my_tool --bad")).
      to be_a_failure.and have_stdout("Oh no!")
  end
end
```

However these assertions can be made with built-in matchers too:

```ruby
require "jet_black"

RSpec.describe "my command line tool" do
  let(:session) { JetBlack::Session.new }

  it "does the work" do
    result = session.run("my_tool --good")

    expect(result.stdout).to match(/It worked/)
    expect(result.exit_status).to eq 0
  end

  it "explodes with incorrect arguments" do
    result = session.run("my_tool --bad")

    expect(result.stdout).to match("Oh no!")
    expect(result.exit_status).to eq 1
  end
end
```
