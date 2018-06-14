require "jet_black"

RSpec.describe JetBlack::Session, "#run" do
  it "captures the stdout" do
    result = subject.run("echo foo")

    expect(result.stdout).to eq "foo"
    expect(result.stderr).to be_empty
  end

  it "captures the stderr" do
    result = subject.run("echo foo 1>&2")

    expect(result.stderr).to eq "foo"
    expect(result.stdout).to be_empty
  end

  it "captures the exit status" do
    expect(subject.run("echo 123").exit_status).to eq 0
    expect(subject.run("! echo 123").exit_status).to be > 0
  end

  it "switches to the working directory" do
    pwd = subject.run("pwd").stdout

    expect(pwd).to eq subject.directory
  end

  it "records the command executed" do
    raw_command = "echo foo"
    result = subject.run(raw_command)

    expect(result.raw_command).to eq raw_command
  end

  it "maintains a history of commands" do
    expect(subject.commands).to be_empty

    result1 = subject.run("echo 123")
    result2 = subject.run("echo 456")

    expect(subject.commands).to eq [result1, result2]
  end
end
