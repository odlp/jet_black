# frozen_string_literal: true

require "fileutils"
require "open3"
require "tmpdir"
require_relative "errors"
require_relative "executed_command"

module JetBlack
  class Session
    attr_reader :commands

    def initialize
      @commands = []
    end

    def run(raw_command, env: {})
      executed_command = run_command(raw_command, env)
      commands << executed_command
      executed_command
    end

    def directory
      @_directory ||= File.realpath(Dir.mktmpdir("jet_black"))
    end

    def create_file(file_path, file_content)
      expanded_file_path = File.expand_path(file_path, directory)
      expanded_dir = File.dirname(expanded_file_path)

      unless expanded_file_path.start_with?(directory)
        raise JetBlack::InvalidPathError.new(file_path, expanded_file_path)
      end

      FileUtils.mkdir_p(expanded_dir)
      File.write(expanded_file_path, file_content)
    end

    private

    def run_command(raw_command, raw_env)
      env = stringify_env(raw_env)

      Dir.chdir(directory) do
        stdout, stderr, exit_status = Open3.capture3(env, raw_command)
        ExecutedCommand.new(
          raw_command: raw_command,
          stdout: stdout,
          stderr: stderr,
          exit_status: exit_status,
        )
      end
    end

    def stringify_env(env)
      env.map do |key, value|
        [key.to_s, value.to_s]
      end.to_h
    end
  end
end
