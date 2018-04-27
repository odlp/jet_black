# JetBlack

[![CircleCI](https://circleci.com/gh/odlp/jet_black.svg?style=svg)](https://circleci.com/gh/odlp/jet_black)

A black-box testing utility for command line tools, written in Ruby. Features:

- Each session runs in a temporary directory
- Captures `stdout`, `stderr` and exit status of a command
- Keeps a history of commands executed
- Temporarily overriding environment variables for a command
- Copying fixture files to the temporary directory
- Appending content to files in the temporary directory
- Adding a path prefix to include your executable
- Option to escape the Bundler environment (allowing `bundle exec` with
  different Gemfiles)
- RSpec matchers for `stdout` and `stderr`
