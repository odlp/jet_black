module JetBlack
  class ExecutedCommand
    attr_reader :raw_command, :stdout, :stderr, :exit_status

    def initialize(raw_command:, stdout:, stderr:, exit_status:)
      @raw_command = raw_command
      @stdout = stdout.chomp
      @stderr = stderr.chomp
      @exit_status = exit_status.to_i
    end
  end
end
