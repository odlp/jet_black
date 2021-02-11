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
    end

    def expect(expected_value, reply:, timeout: DEFAULT_TIMEOUT)
      output_matches = output.expect(expected_value, timeout)

      if output_matches.nil?
        end_session(signal: "KILL")
        raise TerminalSessionTimeoutError.new(self, expected_value, timeout)
      end

      raw_captured_output.concat(output_matches)
      input.puts(reply)
    end

    def captured_output
      raw_captured_output.join.gsub("\r", "")
    end

    def wait_for_finish
      return if finished?

      drain_output
      input.close
      output.close

      _, pty_status = Process.waitpid2(pid)
      self.exit_status = pty_status.exitstatus
    end

    def end_session(signal: "INT")
      Process.kill(signal, pid)

      drain_output
      input.close
      output.close

      _, pty_status = Process.waitpid2(pid)
      self.exit_status = pty_status.exitstatus || pty_status.termsig
    end

    def finished?
      !exit_status.nil?
    end

    private

    attr_accessor :raw_captured_output
    attr_reader :input, :output, :pid
    attr_writer :exit_status

    def drain_output
      until output.eof? do
        raw_captured_output << output.readline
      end
    rescue Errno::EIO => e
      warn("Rescued #{e.message}") if ENV.key?("DEBUG")
    end
  end
end
