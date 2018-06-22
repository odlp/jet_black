require_relative "ansi_scrubber"

module JetBlack
  class ExecutedCommand
    attr_reader :raw_command, :raw_stdout, :raw_stderr,
                :stdout, :stderr, :exit_status

    def initialize(raw_command:, stdout:, stderr:, exit_status:)
      @raw_command = raw_command
      @raw_stdout = stdout
      @raw_stderr = stderr
      @stdout = scrub(stdout)
      @stderr = scrub(stderr)
      @exit_status = exit_status.to_i
    end

    def success?
      exit_status.zero?
    end

    def failure?
      !success?
    end

    private

    def scrub(output_string)
      AnsiScrubber.call(output_string.to_s)
    end
  end
end
