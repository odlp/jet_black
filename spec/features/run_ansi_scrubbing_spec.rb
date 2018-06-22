require "jet_black"

RSpec.describe JetBlack::Session, "ANSI scrubbing" do
  describe "stdout" do
    it "scrubs ANSI color escape sequences" do
      subject.create_executable "print-green", <<~SH
        #!/bin/sh
        printf "\033[1;32mThis is green text\033[0m\n"
      SH

      result = subject.run("./print-green")

      expect(result.stdout).to eq "This is green text"
    end
  end

  describe "stderr" do
    it "scrubs ANSI color escape sequences" do
      subject.create_executable "print-red", <<~SH
        #!/bin/sh
        printf "\033[1;31mThis is red text\033[0m\n"
      SH

      result = subject.run("./print-red 1>&2")

      expect(result.stderr).to eq "This is red text"
    end
  end
end
