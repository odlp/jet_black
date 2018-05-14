# frozen_string_literal: true

require "jet_black"

RSpec.describe JetBlack::Session, "#run with stdin" do
  it "allows stdin data to be passed to the process" do
    subject.create_executable "hello-world", <<~SH
      #!/bin/sh

      echo "What's your name?"
      read name
      echo "Hello $name"
    SH

    result = subject.run("./hello-world", stdin: "Alice")

    expect(result).to be_a_success
    expect(result.stdout).to eq <<~TXT
      What's your name?
      Hello Alice
    TXT
  end
end
