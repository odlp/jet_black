require "pty"
require "expect"
require_relative "errors"

module JetBlack
  class TerminalSession
    DEFAULT_TIMEOUT = 10

    attr_reader :exit_status

    def initialize(raw_command)
      @output, @input, @pid = PTY.spawn(raw_command)
      self.raw_captured_output = []
      self.killed = false
    end

    def expect(expected_value, reply:, timeout: DEFAULT_TIMEOUT)
      output_matches = output.expect(expected_value, timeout)

      if output_matches.nil?
        kill_session!
        raise TerminalSessionTimeoutError.new(self, expected_value, timeout)
      end

      raw_captured_output.concat(output_matches)
      input.puts(reply)
    end

    def captured_output
      raw_captured_output.join.gsub("\r", "")
    end

    def finalize
      raw_captured_output.concat([output.read])
      input.close
      output.close
      Process.waitpid(pid)
      self.exit_status = $?.exitstatus
    end

    def kill_session!
      input.close
      output.close
      self.exit_status = Process.kill(9, pid)
      self.killed = true
    end

    def killed?
      killed
    end

    private

    attr_accessor :killed, :raw_captured_output
    attr_reader :input, :output, :pid
    attr_writer :exit_status
  end
end
