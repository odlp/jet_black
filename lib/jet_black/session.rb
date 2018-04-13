# frozen_string_literal: true

require "tmpdir"
require "open3"

module JetBlack
  class Session
    attr_reader :commands

    def initialize
      @commands = []
    end

    def run(raw_command)
      executed_command = run_command(raw_command)
      commands << executed_command
      executed_command
    end

    def directory
      @_directory ||= File.realpath(Dir.mktmpdir("jet_black"))
    end

    private

    def run_command(raw_command)
      Dir.chdir(directory) do
        stdout, stderr, exit_status = Open3.capture3(raw_command)
        ExecutedCommand.new(
          raw_command,
          stdout.chomp,
          stderr.chomp,
          exit_status.to_i,
        )
      end
    end

    ExecutedCommand = Struct.new(:raw_command, :stdout, :stderr, :exit_status)
  end
end
