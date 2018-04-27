require "jet_black"

RSpec.describe JetBlack::Session, "path prefix" do
  after do
    JetBlack.reset!
  end

  let(:gem_bin_path) { File.expand_path("../../../bin", __dir__) }

  it "allows paths to be prefixed to the current path" do
    JetBlack.configuration.path_prefix = gem_bin_path

    actual_path = subject.run("echo $PATH").stdout
    expected_path = "#{gem_bin_path}:#{ENV['PATH']}"

    expect(actual_path).to eq(expected_path)
    expect(subject.run("jet_black_bin_example").stdout).
      to eq "Hello from example bin"
  end

  it "doesn't mutate the path of the current process" do
    original_path = ENV["PATH"].dup
    JetBlack.configuration.path_prefix = gem_bin_path

    subject.run("echo $PATH")

    expect(ENV["PATH"]).to eq original_path
  end
end
