require "jet_black"

RSpec.describe JetBlack::Session, "#run_interactive" do
  it "allows interactive commands to be run" do
    subject.create_executable "hello-world", <<~SH
      #!/bin/sh

      echo "What's your name?"
      read name
      echo "What's your location?"
      read location
      echo "Hello ${name} in ${location}"
    SH

    result = subject.run_interactive("./hello-world") do |terminal|
      terminal.expect("What's your name?", reply: "Alice")
      terminal.expect("What's your location?", reply: "Wonderland")
    end

    expected_output = <<~TXT
      What's your name?
      Alice
      What's your location?
      Wonderland
      Hello Alice in Wonderland
    TXT

    expect(result.stdout).to eq expected_output
    expect(result.exit_status).to eq 0
  end

  it "raises an error if the expected value isn't found" do
    subject.create_executable "hello-world", <<~SH
      #!/bin/sh

      echo "What's your name?"
      read name
      echo "Hello $name"
    SH

    run_session_with_error = Proc.new do
      subject.run_interactive("./hello-world") do |terminal|
        terminal.expect("Foo bar", reply: "baz", timeout: 0.1)
      end
    end

    expected_error = JetBlack::TerminalSessionTimeoutError

    expect(run_session_with_error).to raise_error(expected_error) do |e|
      expect(e.terminal).to be_killed
      expect(e.terminal.exit_status).to be > 0

      expect(e.message).to eq <<~MSG
        Interactive terminal session timed out after 0.1 second(s).
        Waiting for: 'Foo bar'
      MSG
    end
  end

  describe "clean_bundler_env option" do
    it "allows a clean environment without Bundler variables" do
      expect(ENV["BUNDLE_GEMFILE"]).to_not be_empty

      default_command = subject.run_interactive("echo $BUNDLE_GEMFILE")
      expect(default_command.stdout.chomp).to eq ENV["BUNDLE_GEMFILE"]

      clean_command = subject.run_interactive(
        "echo $BUNDLE_GEMFILE",
        options: { clean_bundler_env: true },
      )

      expect(clean_command.stdout.chomp).to be_empty
    end
  end
end
