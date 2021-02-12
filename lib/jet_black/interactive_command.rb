require_relative "environment"
require_relative "terminal_session"

module JetBlack
  class InteractiveCommand
    def call(raw_command:, raw_env:, directory:, block:)
      env = Environment.new(raw_env).to_h
      terminal = TerminalSession.new(raw_command, env: env, directory: directory)

      unless block.nil?
        block.call(terminal)
      end

      terminal.wait_for_finish

      ExecutedCommand.new(
        raw_command: raw_command,
        stdout: terminal.stdout,
        stderr: terminal.stderr,
        exit_status: terminal.exit_status,
      )
    end
  end
end
