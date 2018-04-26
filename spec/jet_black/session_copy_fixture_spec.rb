require "jet_black"

RSpec.describe JetBlack::Session, "#copy_fixture" do
  it "copies the fixture file to the working directory" do
    configure_fixture_directory(File.expand_path("../fixtures", __dir__))

    subject.copy_fixture("a-original.txt", "a-copied.txt")
    fixture_content = subject.run("cat a-copied.txt").stdout

    expect(fixture_content).to eq "I'm a fixture"
  end

  it "creates sub-directories if required" do
    configure_fixture_directory(File.expand_path("../fixtures", __dir__))

    subject.copy_fixture("a-original.txt", "nested/deep/a-copied.txt")
    fixture_content = subject.run("cat nested/deep/a-copied.txt").stdout

    expect(fixture_content).to eq "I'm a fixture"
  end

  it "raises an error trying to write a file outside the working directory" do
    configure_fixture_directory(File.expand_path("../fixtures", __dir__))

    copy_file_to_outside_tmp_dir = Proc.new do
      subject.copy_fixture("a-original.txt", "../a-copied.txt")
    end

    expected_error = JetBlack::InvalidPathError

    expect(copy_file_to_outside_tmp_dir).to raise_error(expected_error) do |e|
      expect(e.raw_path).to eq "../a-copied.txt"
      expect(e.expanded_path).to_not be_empty
    end
  end

  it "raises an error when the fixture_directory isn't configured" do
    configure_fixture_directory(nil)

    copy_fixture = Proc.new do
      subject.copy_fixture("a-original.txt", "a-copied.txt")
    end

    expect(copy_fixture).to raise_error(JetBlack::Error) do |e|
      expect(e.message).to eq "Please configure the fixture_directory"
    end
  end

  private

  def configure_fixture_directory(path)
    JetBlack.configure do |config|
      config.fixture_directory = path
    end
  end
end
