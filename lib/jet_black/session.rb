# frozen_string_literal: true

require "fileutils"
require "open3"
require "tmpdir"
require_relative "environment"
require_relative "errors"
require_relative "executed_command"

module JetBlack
  class Session
    attr_reader :commands

    def initialize(options: {})
      @commands = []
      @session_options = options
    end

    def run(command, env: {}, options: {})
      combined_options = session_options.merge(options)
      executed_command = exec_command(command, env, combined_options)
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

    def append_to_file(file_path, append_content)
      expanded_file_path = File.expand_path(file_path, directory)

      unless File.exist?(expanded_file_path)
        raise JetBlack::NonExistentFileError.new(file_path, expanded_file_path)
      end

      File.open(expanded_file_path, "a") do |file|
        file.write(append_content)
      end
    end

    def copy_fixture(source_path, destination_path)
      src_fixture_dir = JetBlack.configuration.fixture_directory
      expanded_source_path = File.expand_path(source_path, src_fixture_dir)
      expanded_destination_path = File.expand_path(destination_path, directory)
      expanded_destination_dir = File.dirname(expanded_destination_path)

      if src_fixture_dir.nil?
        raise Error.new("Please configure the fixture_directory")
      end

      unless expanded_destination_path.start_with?(directory)
        raise JetBlack::InvalidPathError.new(
          destination_path, expanded_destination_path
        )
      end

      FileUtils.mkdir_p(expanded_destination_dir)
      FileUtils.cp(expanded_source_path, expanded_destination_path)
    end

    private

    attr_reader :session_options

    def exec_command(raw_command, raw_env, options)
      env = Environment.new(raw_env).to_h

      command_context(options) do
        stdout, stderr, exit_status =
          Open3.capture3(env, raw_command, chdir: directory)

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
