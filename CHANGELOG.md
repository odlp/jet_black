# Changelog

## Unreleased

- Scrub ANSI escape sequences in stdout and stderr
- Allow environment variables to be unset

## v0.3.0

- Allows `stdin` data to be provided when running commands
- Adds `create_executable` to which writes a file and adds execute permission

## v0.2.0

- Adds RSpec matchers `have_stdout`, `have_stderr`, `have_no_stdout`, &
  `have_no_stderr`.
- Adds support for RSpec predicate matchers `be_success` & `be_failure`.
- Requiring `jet_black/rspec` sets up inference of spec type and inclusion
  matchers (place specs in `spec/black_box`).

## v0.1.0

- Initial release.
