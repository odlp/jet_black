# frozen_string_literal: true

require "fileutils"
require_relative "errors"

module JetBlack
  class FileHelper
    def initialize(working_directory)
      @working_directory = working_directory
    end

    def create_file(file_path, file_content)
      resolved_file_path = resolve_working_path(file_path)
      resolved_dir = File.dirname(resolved_file_path)

      FileUtils.mkdir_p(resolved_dir)
      File.write(resolved_file_path, file_content)
    end

    def create_executable(file_path, file_content)
      resolved_file_path = resolve_working_path(file_path)

      create_file(file_path, file_content)
      FileUtils.chmod("+x", resolved_file_path)
    end

    def append_to_file(file_path, append_content)
      resolved_file_path = resolve_working_path(file_path)

      unless File.exist?(resolved_file_path)
        raise JetBlack::NonExistentFileError.new(file_path, resolved_file_path)
      end

      File.open(resolved_file_path, "a") do |file|
        file.write(append_content)
      end
    end

    def copy_fixture(source_path, destination_path)
      source_fixture_dir = JetBlack.configuration.fixture_directory
      resolved_source_path = File.expand_path(source_path, source_fixture_dir)

      resolved_destination_path = resolve_working_path(destination_path)
      resolved_destination_dir = File.dirname(resolved_destination_path)

      if source_fixture_dir.nil?
        raise Error.new("Please configure the fixture_directory")
      end

      FileUtils.mkdir_p(resolved_destination_dir)
      FileUtils.cp(resolved_source_path, resolved_destination_path)
    end

    private

    attr_reader :working_directory

    def resolve_working_path(file_path)
      resolved_file_path = File.expand_path(file_path, working_directory)

      unless resolved_file_path.start_with?(working_directory)
        raise JetBlack::InvalidPathError.new(file_path, resolved_file_path)
      end

      resolved_file_path
    end
  end
end
