require "jet_black/terminal_session"

RSpec.describe JetBlack::TerminalSession do
  describe "#wait_for_finish" do
    it "closes the input, stdout and stderr IO" do
      open_and_wait = Proc.new do
        described_class.new("echo foo", env: {}, directory: __dir__).wait_for_finish
      end

      expect(open_and_wait).to_not change { open_file_descriptor_count }
    end
  end

  describe "#end_session" do
    it "closes the input, stdout and stderr IO" do
      open_and_end = Proc.new do
        described_class.new("echo foo", env: {}, directory: __dir__).end_session
      end

      expect(open_and_end).to_not change { open_file_descriptor_count }
    end

    it "gracefully handles processes which are already dead" do
      session = described_class.new("sleep 30", env: {}, directory: __dir__)

      # Terminate process ourselves, so the session encounters Errno::ESRCH
      Process.kill("INT", session.pid)

      expect { session.end_session }.to_not raise_exception
      expect(session.exit_status).to eq(Signal.list["INT"])
    end
  end

  private

  def open_file_descriptor_count
    ObjectSpace.each_object(IO).reject(&:closed?).count
  end
end
