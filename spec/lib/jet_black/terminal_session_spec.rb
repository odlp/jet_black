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
  end

  private

  def open_file_descriptor_count
    ObjectSpace.each_object(IO).reject(&:closed?).count
  end
end
