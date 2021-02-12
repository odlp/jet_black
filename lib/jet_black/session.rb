# frozen_string_literal: true

require "bundler"
require "fileutils"
require "forwardable"
require "tmpdir"
require_relative "errors"
require_relative "executed_command"
require_relative "file_helper"
require_relative "non_interactive_command"
require_relative "interactive_command"

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
      exec_non_interactive(raw_command: command, stdin: stdin, raw_env: env, options: options).tap do |executed_command|
        commands << executed_command
      end
    end

    def run_interactive(command, options: {}, &block)
      exec_interactive(raw_command: command, options: options, block: block).tap do |executed_command|
        commands << executed_command
      end
    end

    private

    attr_reader :session_options, :file_helper

    def exec_non_interactive(raw_command:, stdin:, raw_env:, options:)
      combined_options = session_options.merge(options)

      execution_context(combined_options) do
        NonInteractiveCommand.new.call(raw_command: raw_command, stdin: stdin, raw_env: raw_env, directory: directory)
      end
    end

    def exec_interactive(raw_command:, options:, block:)
      combined_options = session_options.merge(options)

      execution_context(combined_options) do
        InteractiveCommand.new.call(raw_command: raw_command, directory: directory, block: block)
      end
    end

    def execution_context(options)
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
