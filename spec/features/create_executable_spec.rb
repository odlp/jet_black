require "jet_black"

RSpec.describe JetBlack::Session, "#create_executable" do
  it "creates the file and sets permissions" do
    subject.create_executable "hello-world", <<~SH
      #!/bin/sh
      echo "Hello world"
    SH

    result = subject.run("./hello-world")

    expect(result.stdout).to match "Hello world"
    expect(result).to be_a_success
  end
end
