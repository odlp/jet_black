require_relative "environment"
require_relative "terminal_session"

module JetBlack
  class InteractiveCommand
    def call(raw_command:, directory:, block:)
      terminal = TerminalSession.new(raw_command, directory: directory)

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
