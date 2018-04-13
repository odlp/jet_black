require "jet_black/session"

RSpec.describe JetBlack::Session do
  describe "#directory" do
    it "is within the temporary directory" do
      tmp_directory = `echo $TMPDIR`.chomp

      expect(subject.directory).to start_with tmp_directory
    end

    it "re-uses the same directory within a session" do
      expect(subject.directory).to eq subject.directory
    end

    it "includes jet_black in the directory name" do
      expect(subject.directory).to include "jet_black"
    end

    it "assigns a unique temporary directory per session" do
      session_a = described_class.new
      session_b = described_class.new

      expect(session_a.directory).to_not eq session_b.directory
    end
  end
end
