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

  describe "deadlock prevention" do
    # From docs - https://ruby-doc.org/stdlib-3.0.0/libdoc/open3/rdoc/Open3.html#method-c-popen3
    # You should be careful to avoid deadlocks. Since pipes are fixed length buffers,
    # Open3.popen3(“prog”) {|i, o, e, t| o.read } deadlocks if the program generates too much output on stderr.
    # You should read stdout and stderr simultaneously (using threads or IO.select).

    it "does not deadlock on large volumes of STDERR and STDOUT output" do
      command = "ruby -e '1_000.times { |n| puts \"a\" * 100; warn \"z\" * 100 }; puts \"Bye\"'"
      session = described_class.new(command, env: {}, directory: __dir__)
      session.expect("Bye")

      session.wait_for_finish

      expect(session.exit_status).to be_zero
      expect(session.stdout).to include("Bye")
      expect(session.stdout.count("\n")).to be >= 1_001
      expect(session.stderr.count("\n")).to be >= 1_000
    end
  end

  private

  def open_file_descriptor_count
    ObjectSpace.each_object(IO).reject(&:closed?).count
  end
end
