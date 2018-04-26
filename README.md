# JetBlack

A black-box testing utility for Ruby. Features:

- Each session runs in a temporary directory
- Captures stdout, stderr and exit status of a command
- Keeps a history of commands executed
- Temporarily overriding environment variables for a command
- Copying fixture files to the temporary directory
- Adding a path prefix to include your executable
- Option to escape the Bundler environment, to "bundle exec" new Gemfiles
