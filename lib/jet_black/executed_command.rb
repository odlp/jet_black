require_relative "ansi_scrubber"

module JetBlack
  class ExecutedCommand
    attr_reader :raw_command, :stdout, :stderr, :exit_status

    def initialize(raw_command:, stdout:, stderr:, exit_status:)
      @raw_command = raw_command
      @stdout = AnsiScrubber.call(stdout.chomp)
      @stderr = AnsiScrubber.call(stderr.chomp)
      @exit_status = exit_status.to_i
    end

    def success?
      exit_status.zero?
    end

    def failure?
      !success?
    end
  end
end
