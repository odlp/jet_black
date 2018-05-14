# frozen_string_literal: true

require "fileutils"
require "forwardable"
require "open3"
require "tmpdir"
require_relative "environment"
require_relative "errors"
require_relative "executed_command"
require_relative "file_helper"

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

    def command_context(options)
      if options[:clean_bundler_env]
        Bundler.with_clean_env { yield }
      else
        yield
      end
    end
  end
end
