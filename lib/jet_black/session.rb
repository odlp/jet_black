# frozen_string_literal: true

require "bundler"
require "fileutils"
require "forwardable"
require "open3"
require "tmpdir"
require_relative "environment"
require_relative "errors"
require_relative "executed_command"
require_relative "file_helper"
require_relative "terminal_session"

module JetBlack
  class Session
    extend Forwardable

    def_delegators :file_helper, :create_file, :create_executable,
                   :append_to_file, :copy_fixture

    attr_reader :commands, :directory

    def initialize(options: {})
      @commands = []
      @session_options = options
      @directory = File.realpath(Dir.mktmpdir("jet_black"))
      @file_helper = FileHelper.new(directory)
    end

    def run(command, stdin: nil, env: {}, options: {})
      combined_options = session_options.merge(options)
      executed_command = exec_command(command, stdin, env, combined_options)
      commands << executed_command
      executed_command
    end

    def run_interactive(command, options: {}, &block)
      combined_options = session_options.merge(options)

      executed_command =
        exec_interactive_command(command, combined_options, block)

      commands << executed_command
      executed_command
    end

    private

    attr_reader :session_options, :file_helper

    def exec_command(raw_command, stdin, raw_env, options)
      env = Environment.new(raw_env).to_h

      command_context(options) do
        stdout, stderr, exit_status =
          Open3.capture3(env, raw_command, chdir: directory, stdin_data: stdin)

        ExecutedCommand.new(
          raw_command: raw_command,
          stdout: stdout,
          stderr: stderr,
          exit_status: exit_status,
        )
      end
    end

    def exec_interactive_command(raw_command, options, block)
      Dir.chdir(directory) do
        command_context(options) do
          terminal = TerminalSession.new(raw_command)

          unless block.nil?
            block.call(terminal)
          end

          terminal.wait_for_finish

          ExecutedCommand.new(
            raw_command: raw_command,
            stdout: terminal.captured_output,
            stderr: nil,
            exit_status: terminal.exit_status,
          )
        end
      end
    end

    def command_context(options)
      if options[:clean_bundler_env]
        Bundler.public_send(bundler_clean_environment_method) { yield }
      else
        yield
      end
    end

    def bundler_clean_environment_method
      # Bundler 2.x
      if Bundler.respond_to?(:with_unbundled_env)
        :with_unbundled_env
      else
        :with_clean_env
      end
    end
  end
end
