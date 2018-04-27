require "jet_black/executed_command"
require "jet_black/rspec/matchers"

RSpec.describe JetBlack::RSpec::Matchers do
  include described_class

  describe "#have_stdout" do
    it "matches with a regex" do
      expect(executed_command(stdout: "foo bar")).to have_stdout(/bar/)
      expect(executed_command(stdout: "foo bar")).to_not have_stdout(/moo/)
    end

    it "matches with a string" do
      expect(executed_command(stdout: "foo bar")).to have_stdout("bar")
      expect(executed_command(stdout: "foo bar")).to_not have_stdout("moo")
    end

    it "has a helpful error message" do
      matcher = have_stdout("woof")
      matcher.matches? executed_command(stdout: "moo")

      expect(matcher.failure_message).to eq 'expected "moo" to match "woof"'
    end
  end

  describe "#have_stderr" do
    it "matches with a regex" do
      expect(executed_command(stderr: "foo bar")).to have_stderr(/bar/)
      expect(executed_command(stderr: "foo bar")).to_not have_stderr(/moo/)
    end

    it "matches with a string" do
      expect(executed_command(stderr: "foo bar")).to have_stderr("bar")
      expect(executed_command(stderr: "foo bar")).to_not have_stderr("moo")
    end

    it "has a helpful error message" do
      matcher = have_stderr("woof")
      matcher.matches? executed_command(stderr: "moo")

      expect(matcher.failure_message).to eq 'expected "moo" to match "woof"'
    end
  end

  describe "#have_no_stdout" do
    it "matches when there's no stdout output" do
      expect(executed_command(stdout: "")).to have_no_stdout
    end

    it "has a helpful error message" do
      matcher = have_no_stdout
      matcher.matches? executed_command(stdout: "moo")

      expect(matcher.failure_message).to eq <<~MSG
        expected command to have no stdout output. Got:
        ---
        moo
      MSG
    end
  end

  describe "#have_no_stderr" do
    it "matches when there's no stderr output" do
      expect(executed_command(stderr: "")).to have_no_stderr
    end

    it "has a helpful error message" do
      matcher = have_no_stderr
      matcher.matches? executed_command(stderr: "moo")

      expect(matcher.failure_message).to eq <<~MSG
        expected command to have no stderr output. Got:
        ---
        moo
      MSG
    end
  end

  private

  def executed_command(stdout: "", stderr: "")
    JetBlack::ExecutedCommand.new(
      raw_command: "",
      stdout: stdout,
      stderr: stderr,
      exit_status: 0,
    )
  end
end
