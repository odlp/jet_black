# frozen_string_literal: true

require "tmpdir"
require "open3"

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

    private

    def run_command(raw_command, raw_env)
      env = stringify_env(raw_env)

      Dir.chdir(directory) do
        stdout, stderr, exit_status = Open3.capture3(env, raw_command)
        ExecutedCommand.new(
          raw_command,
          stdout.chomp,
          stderr.chomp,
          exit_status.to_i,
        )
      end
    end

    def stringify_env(env)
      env.map do |key, value|
        [key.to_s, value.to_s]
      end.to_h
    end

    ExecutedCommand = Struct.new(:raw_command, :stdout, :stderr, :exit_status)
  end
end
