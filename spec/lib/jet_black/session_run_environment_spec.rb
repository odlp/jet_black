require "jet_black"
require "support/environment_support"

RSpec.describe JetBlack::Session, "environment" do
  include EnvironmentSupport

  it "allows overrides without affecting the current process" do
    with_environment("FOO" => "bar") do
      expect(ENV["FOO"]).to eq "bar"

      plain_command = subject.run("echo $FOO")
      expect(plain_command.stdout).to eq "bar"

      expect(ENV["FOO"]).to eq "bar"

      modified_env_command = subject.run("echo $FOO", env: { "FOO" => "123" })
      expect(modified_env_command.stdout).to eq "123"

      expect(ENV["FOO"]).to eq "bar"
    end
  end

  it "allows overrides with symbol keys" do
    command = subject.run("echo $FOO", env: { FOO: "bar" })

    expect(command.stdout).to eq "bar"
  end

  it "allows overrides with non-string values" do
    command_1 = subject.run("echo $FOO", env: { "FOO" => 123 })
    expect(command_1.stdout).to eq "123"

    command_2 = subject.run("echo $FOO", env: { "FOO" => :bar })
    expect(command_2.stdout).to eq "bar"
  end

  it "allows environment variables to be unset" do
    with_environment("FOO" => "bar") do
      result =
        subject.run(%q(ruby -e 'puts ENV.key?("FOO")'), env: { "FOO" => nil })

      expect(result.stdout).to(include("false"), "$FOO should be unset")
    end
  end

  describe "clean_bundler_env option" do
    it "allows a clean environment without Bundler variables" do
      expect(ENV["BUNDLE_GEMFILE"]).to_not be_empty

      default_command = subject.run("echo $BUNDLE_GEMFILE")
      expect(default_command.stdout).to eq ENV["BUNDLE_GEMFILE"]

      options = { clean_bundler_env: true }
      clean_command = subject.run("echo $BUNDLE_GEMFILE", options: options)
      expect(clean_command.stdout).to be_empty
    end

    it "allows the option to specified for the whole session" do
      session = described_class.new(options: { clean_bundler_env: true })
      clean_command = session.run("echo $BUNDLE_GEMFILE")

      expect(clean_command.stdout).to be_empty
    end

    it "allows the option to be overriden for a specific command" do
      session = described_class.new(options: { clean_bundler_env: true })

      command = session.run(
        "echo $BUNDLE_GEMFILE", options: { clean_bundler_env: false }
      )

      expect(command.stdout).to eq ENV["BUNDLE_GEMFILE"]
    end
  end
end
