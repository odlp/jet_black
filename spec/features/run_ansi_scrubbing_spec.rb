require "jet_black"

RSpec.describe JetBlack::Session, "ANSI scrubbing" do
  describe "stdout" do
    it "scrubs ANSI color escape sequences" do
      create_printer("print-green", '\033[1;32mThis is green text\033[0m\n')

      result = subject.run("./print-green")

      expect(result.stdout).to eq "This is green text"
    end

    it "preserves the original output in #raw_stdout" do
      create_printer("print-green", '\033[1;32mThis is green text\033[0m\n')

      result = subject.run("./print-green")

      expect(result.raw_stdout).to eq "\e[1;32mThis is green text\e[0m\n"
    end
  end

  describe "stderr" do
    it "scrubs ANSI color escape sequences" do
      create_printer("print-red", '\033[1;31mThis is red text\033[0m\n')

      result = subject.run("./print-red 1>&2")

      expect(result.stderr).to eq "This is red text"
    end

    it "preserves the original output in #raw_stderr" do
      create_printer("print-red", '\033[1;31mThis is red text\033[0m\n')

      result = subject.run("./print-red 1>&2")

      expect(result.raw_stderr).to eq "\e[1;31mThis is red text\e[0m\n"
    end
  end

  private

  def create_printer(printer_name, string)
    subject.create_executable printer_name, <<~SH
      #!/bin/sh
      printf "#{string}"
    SH
  end
end
