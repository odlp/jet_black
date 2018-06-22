require "jet_black"
require "support/environment_support"

RSpec.describe JetBlack::Session, "environment" do
  include EnvironmentSupport

  it "allows overrides without affecting the current process" do
    with_environment("FOO" => "bar") do
      expect(ENV["FOO"]).to eq "bar"

      plain_result = subject.run("printf $FOO")
      expect(plain_result.stdout).to eq "bar"

      expect(ENV["FOO"]).to eq "bar"

      modified_env_result = subject.run("printf $FOO", env: { "FOO" => "123" })
      expect(modified_env_result.stdout).to eq "123"

      expect(ENV["FOO"]).to eq "bar"
    end
  end

  it "allows overrides with symbol keys" do
    result = subject.run("printf $FOO", env: { FOO: "bar" })

    expect(result.stdout).to eq "bar"
  end

  it "allows overrides with non-string values" do
    result1 = subject.run("printf $FOO", env: { "FOO" => 123 })
    expect(result1.stdout).to eq "123"

    result2 = subject.run("printf $FOO", env: { "FOO" => :bar })
    expect(result2.stdout).to eq "bar"
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

      default_result = subject.run("printf $BUNDLE_GEMFILE")
      expect(default_result.stdout).to eq ENV["BUNDLE_GEMFILE"]

      options = { clean_bundler_env: true }
      clean_result = subject.run("printf $BUNDLE_GEMFILE", options: options)
      expect(clean_result.stdout).to be_empty
    end

    it "allows the option to specified for the whole session" do
      session = described_class.new(options: { clean_bundler_env: true })
      clean_result = session.run("printf $BUNDLE_GEMFILE")

      expect(clean_result.stdout).to be_empty
    end

    it "allows the option to be overriden for a specific result" do
      session = described_class.new(options: { clean_bundler_env: true })

      result = session.run(
        "printf $BUNDLE_GEMFILE", options: { clean_bundler_env: false }
      )

      expect(result.stdout).to eq ENV["BUNDLE_GEMFILE"]
    end
  end
end
