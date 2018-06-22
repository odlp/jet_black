require "jet_black/executed_command"

RSpec.describe JetBlack::ExecutedCommand do
  describe "#success?" do
    it "is true when the exit status is zero" do
      expect(zero_exit.success?).to be true
      expect(non_zero_exit.success?).to be false
    end

    it "allows predicate matchers to be used" do
      expect(zero_exit).to be_success
      expect(zero_exit).to be_a_success

      expect(non_zero_exit).to_not be_success
      expect(non_zero_exit).to_not be_a_success
    end
  end

  describe "#failure?" do
    it "allows predicate matchers to be used" do
      expect(non_zero_exit).to be_failure
      expect(non_zero_exit).to be_a_failure

      expect(zero_exit).to_not be_failure
      expect(zero_exit).to_not be_a_failure
    end
  end

  describe "#stdout" do
    it "tolerates nil stdout" do
      expect(executed_command(stdout: nil).stdout).to eq ""
    end
  end

  describe "#stderr" do
    it "tolerates nil stderr" do
      expect(executed_command(stderr: nil).stderr).to eq ""
    end
  end

  private

  def zero_exit
    executed_command(exit_status: 0)
  end

  def non_zero_exit
    executed_command(exit_status: 1)
  end

  def executed_command(exit_status: 0, stdout: "", stderr: "")
    described_class.new(
      raw_command: "",
      stdout: stdout,
      stderr: stderr,
      exit_status: exit_status,
    )
  end
end
