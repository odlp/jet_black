require "pty"
require "expect"
require_relative "errors"

module JetBlack
  class TerminalSession
    DEFAULT_TIMEOUT = 10

    attr_reader :exit_status

    def initialize(raw_command, directory:)
      @stderr_reader, @stderr_writer = IO.pipe
      @output, @input, @pid = PTY.spawn(raw_command, chdir: directory, err: stderr_writer.fileno)
      self.raw_stdout = []
    end

    def expect(expected_value, reply:, timeout: DEFAULT_TIMEOUT)
      output_matches = output.expect(expected_value, timeout)

      if output_matches.nil?
        end_session(signal: "KILL")
        raise TerminalSessionTimeoutError.new(self, expected_value, timeout)
      end

      raw_stdout.concat(output_matches)
      input.puts(reply)
    end

    def stdout
      raw_stdout.join.gsub("\r", "")
    end

    def stderr
      raw_std_err
    end

    def wait_for_finish
      return if finished?

      finalize_io

      self.exit_status = wait_for_exit_status
    end

    def end_session(signal: "INT")
      Process.kill(signal, pid)
      finalize_io

      self.exit_status = wait_for_exit_status
    end

    def finished?
      !exit_status.nil?
    end

    private

    attr_accessor :raw_stdout, :raw_std_err
    attr_reader :input, :output, :pid, :stderr_reader, :stderr_writer
    attr_writer :exit_status

    def finalize_io
      drain_stdout
      drain_stderr
    end

    def wait_for_exit_status
      _, pty_status = Process.waitpid2(pid)
      pty_status.exitstatus || pty_status.termsig
    end

    def drain_stdout
      until output.eof? do
        raw_stdout << output.readline
      end

      input.close
      output.close
    rescue Errno::EIO => e # https://github.com/ruby/ruby/blob/57fb2199059cb55b632d093c2e64c8a3c60acfbb/ext/pty/pty.c#L521
      warn("Rescued #{e.message}") if ENV.key?("DEBUG")
    end

    def drain_stderr
      stderr_writer.close
      self.raw_std_err = stderr_reader.read
    end
  end
end
