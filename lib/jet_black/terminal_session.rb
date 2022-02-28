# frozen_string_literal: true

require "open3"
require "expect"
require_relative "errors"

module JetBlack
  class TerminalSession
    DEFAULT_TIMEOUT = 10
    UNKNOWN_EXIT_STATUS = -1

    attr_reader :exit_status, :stderr, :stdout, :pid

    def initialize(raw_command, env:, directory:)
      @stdin_io, @stdout_io, @stderr_io, @wait_thr = Open3.popen3(env, raw_command, chdir: directory)
      @stderr_reader = setup_io_reader(@stderr_io)
      @pid = wait_thr.pid
      @stdout = +""
      @stderr = +""
    end

    def expect(expected_value, reply: nil, timeout: DEFAULT_TIMEOUT, signal_on_timeout: "KILL")
      output_matches = stdout_io.expect(expected_value, timeout)

      if output_matches.nil?
        end_session(signal: signal_on_timeout)
        raise TerminalSessionTimeoutError.new(self, expected_value, timeout)
      end

      stdout.concat(*output_matches)

      if reply != nil
        stdin_io.puts(reply)
        stdout.concat("\n", reply)
      end
    end

    def wait_for_finish
      return if finished?

      finalize_io
      @exit_status = wait_for_exit_status
    end

    def end_session(signal: "INT")
      begin
        Process.kill(signal, pid)
      rescue Errno::ESRCH
        warn("WARNING: Process is already dead") if ENV.key?("DEBUG")
      end

      finalize_io
      @exit_status = wait_for_exit_status
    end

    def finished?
      !exit_status.nil?
    end

    private

    attr_reader :stdin_io, :stdout_io, :stderr_io, :stderr_reader, :wait_thr

    def setup_io_reader(io)
      Thread.new do
        until io.eof?
          stderr << io.read
        end
      end
    end

    def finalize_io
      stdin_io.close
      drain_stdout
      drain_stderr
    end

    def wait_for_exit_status
      if (process_status = wait_thr.value)
        process_status.exitstatus || process_status.termsig
      else
        UNKNOWN_EXIT_STATUS
      end
    end

    def drain_stdout
      until stdout_io.eof? do
        stdout << stdout_io.read
      end
    ensure
      stdout_io.close
    end

    def drain_stderr
      stderr_reader.join
    ensure
      stderr_io.close
    end
  end
end
