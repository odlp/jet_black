require "jet_black/session"
require "support/environment_support"

RSpec.describe JetBlack::Session do
  include EnvironmentSupport

  describe "#run" do
    it "captures the stdout" do
      command = subject.run("echo foo")

      expect(command.stdout).to eq "foo"
      expect(command.stderr).to be_empty
    end

    it "captures the stderr" do
      command = subject.run("echo foo 1>&2")

      expect(command.stderr).to eq "foo"
      expect(command.stdout).to be_empty
    end

    it "captures the exit status" do
      expect(subject.run("echo 123").exit_status).to eq 0
      expect(subject.run("! echo 123").exit_status).to be > 0
    end

    it "switches to the working directory" do
      executed_command = subject.run("pwd")

      expect(executed_command.stdout).to eq subject.directory
    end

    it "records the command executed" do
      raw_command = "echo foo"
      executed_command = subject.run(raw_command)

      expect(executed_command.raw_command).to eq raw_command
    end

    it "maintains a history of commands" do
      expect(subject.commands).to be_empty

      command_1 = subject.run("echo 123")
      command_2 = subject.run("echo 456")

      expect(subject.commands).to eq [command_1, command_2]
    end

    it "allows environment overrides without affecting the current process" do
      with_environment("FOO" => "bar") do
        expect(ENV["FOO"]).to eq "bar"

        plain_command = subject.run("echo $FOO")
        expect(plain_command.stdout).to eq "bar"

        expect(ENV["FOO"]).to eq "bar"

        modified_env_command = subject.run("echo $FOO", env: { "FOO" => "123" })
        expect(modified_env_command.stdout).to eq "123"

        expect(ENV["FOO"]).to eq "bar"
      end
    end
  end

  describe "#directory" do
    it "is within the temporary directory" do
      tmp_directory = `echo $TMPDIR`.chomp

      # On MacOS /var/x can be a symlink to /private/var/x
      resolved_tmp_directory = File.realpath(tmp_directory)

      expect(subject.directory).to start_with resolved_tmp_directory
    end

    it "re-uses the same directory within a session" do
      expect(subject.directory).to eq subject.directory
    end

    it "includes jet_black in the directory name" do
      expect(subject.directory).to include "jet_black"
    end

    it "assigns a unique temporary directory per session" do
      session_a = described_class.new
      session_b = described_class.new

      expect(session_a.directory).to_not eq session_b.directory
    end
  end
end
