# Changelog

## Unreleased

- Adds `run_interactive` to allow pseudo-terminal interaction

## v0.6.0

- Freeze string literals
- Fix deprecation warning: `Bundler.with_clean_env` has been deprecated in
  favor of `Bundler.with_unbundled_env`

## v0.5.1

- Fix missing `bundler` require - thanks @lpender via [#6][pr-6]

[pr-6]: https://github.com/odlp/jet_black/pull/6

## v0.5.0

- `stdout` and `stderr` now keep any trailing newlines at the end of the string.

## v0.4.0

- Scrub ANSI escape sequences in `stdout` and `stderr`
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
