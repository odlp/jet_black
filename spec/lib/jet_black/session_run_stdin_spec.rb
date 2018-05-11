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

    expected_output = <<~TXT
      What's your name?
      Hello Alice
    TXT

    expect(result.stdout).to eq expected_output.chomp
    expect(result).to be_a_success
  end
end
