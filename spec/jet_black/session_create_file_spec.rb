require "jet_black/session"

RSpec.describe JetBlack::Session, "#create_file" do
  it "writes the contents at the specified path" do
    file_content = <<~FILE
      foo
      bar
      baz
    FILE

    subject.create_file("foo.txt", file_content)
    read_file_content = subject.run("less foo.txt").stdout

    expect(read_file_content).to match file_content.chomp
  end

  it "creates sub-directories if required" do
    subject.create_file("sub/foo.txt", "bar baz")
    read_file_content = subject.run("less sub/foo.txt").stdout

    expect(read_file_content).to match "bar baz"
  end

  describe "handling invalid paths" do
    let(:expected_error) { JetBlack::InvalidPathError }

    it "raises an error trying to write a file outside the working directory" do
      create_file_outside_tmp_dir = Proc.new do
        subject.create_file("../foo.txt", "bar baz")
      end

      expect(create_file_outside_tmp_dir).to raise_error(expected_error) do |e|
        expect(e.raw_path).to eq "../foo.txt"
        expect(e.expanded_path).to_not be_empty
      end
    end

    it "raises an error trying to write a file within the home directory" do
      create_file_within_home_dir = Proc.new do
        subject.create_file("~/test/foo.txt", "bar baz")
      end

      expect(create_file_within_home_dir).to raise_error(expected_error) do |e|
        expect(e.raw_path).to eq "~/test/foo.txt"
        expect(e.expanded_path).to_not be_empty
      end
    end

    it "doesn't write the file" do
      relative_path = "../foo.txt"
      expanded_path = File.expand_path("../foo.txt", subject.directory)

      create_file_outside_tmp_dir = Proc.new do
        subject.create_file(relative_path, "bar baz")
      end

      expect(File.exist?(expanded_path)).to be false
      expect(create_file_outside_tmp_dir).to raise_error(expected_error)
      expect(File.exist?(expanded_path)).to be false
    end
  end
end
