# frozen_string_literal: true

require "jet_black/session"

RSpec.describe JetBlack::Session, "#directory" do
  it "is within the temporary directory" do
    expect(subject.directory).to be_a_temporary_directory
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

  private

  def be_a_temporary_directory
    tmp_directory = ENV.fetch("TMPDIR", "/tmp")

    # On MacOS /var/x can be a symlink to /private/var/x
    resolved_tmp_directory = File.realpath(tmp_directory)

    start_with("/tmp/").or start_with(resolved_tmp_directory)
  end
end
