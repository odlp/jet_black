require "open3"
require_relative "environment"

module JetBlack
  class NonInteractiveCommand
    def call(raw_command:, stdin:, raw_env:, directory:)
      env = Environment.new(raw_env).to_h

      stdout, stderr, exit_status = Open3.capture3(
        env, raw_command, chdir: directory, stdin_data: stdin
      )

      ExecutedCommand.new(
        raw_command: raw_command,
        stdout: stdout,
        stderr: stderr,
        exit_status: exit_status,
      )
    end
  end
end
