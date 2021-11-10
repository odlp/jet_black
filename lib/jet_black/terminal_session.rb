require "open3"
require "expect"
require_relative "errors"

module JetBlack
  class TerminalSession
    DEFAULT_TIMEOUT = 10

    attr_reader :exit_status, :stderr

    def initialize(raw_command, env:, directory:)
      @stdin_io, @stdout_io, @stderr_io, @wait_thr = Open3.popen3(env, raw_command, chdir: directory)
      @chunked_stdout = []
    end

    def expect(expected_value, reply: nil, timeout: DEFAULT_TIMEOUT, signal_on_timeout: "KILL")
      output_matches = stdout_io.expect(expected_value, timeout)

      if output_matches.nil?
        end_session(signal: signal_on_timeout)
        raise TerminalSessionTimeoutError.new(self, expected_value, timeout)
      end

      chunked_stdout.concat(output_matches)

      if reply != nil
        stdin_io.puts(reply)
        chunked_stdout << ("\n" + reply)
      end
    end

    def stdout
      @stdout ||= chunked_stdout.join.gsub("\r", "")
    end

    def wait_for_finish
      return if finished?

      finalize_io
      @exit_status = wait_for_exit_status
    end

    def end_session(signal: "INT")
      Process.kill(signal, wait_thr.pid)
      finalize_io
      @exit_status = wait_for_exit_status
    end

    def finished?
      !exit_status.nil?
    end

    private

    attr_reader :stdin_io, :stdout_io, :stderr_io, :chunked_stdout, :wait_thr

    def finalize_io
      stdin_io.close
      drain_stdout
      drain_stderr
    end

    def wait_for_exit_status
      process_status = wait_thr.value
      process_status.exitstatus || process_status.termsig
    end

    def drain_stdout
      until stdout_io.eof? do
        chunked_stdout << stdout_io.readline
      end
    ensure
      stdout_io.close
    end

    def drain_stderr
      @stderr = stderr_io.read
    ensure
      stderr_io.close
    end
  end
end
