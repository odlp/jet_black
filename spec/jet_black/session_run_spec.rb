require "jet_black/session"
require "support/environment_support"

RSpec.describe JetBlack::Session, "#run" do
  include EnvironmentSupport

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

  describe "environment" do
    it "allows overrides without affecting the current process" do
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

    it "allows overrides with symbol keys" do
      command = subject.run("echo $FOO", env: { FOO: "bar" })

      expect(command.stdout).to eq "bar"
    end

    it "allows overrides with non-string values" do
      command_1 = subject.run("echo $FOO", env: { "FOO" => 123 })
      expect(command_1.stdout).to eq "123"

      command_2 = subject.run("echo $FOO", env: { "FOO" => :bar })
      expect(command_2.stdout).to eq "bar"
    end
  end
end
