require "jet_black"

RSpec.describe JetBlack::Session, "#run with stdin" do
  it "allows stdin data to be passed to the process" do
    subject.create_file "hello-world", <<~SH
      #!/bin/sh

      echo "What's your name?"
      read name
      echo "Hello $name"
    SH

    subject.run("chmod +x hello-world")
    result = subject.run("./hello-world", stdin: "Alice")

    expect(result).to be_a_success
    expect(result.stdout).to eq <<~TXT
      What's your name?
      Hello Alice
    TXT
  end
end
