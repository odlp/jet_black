# frozen_string_literal: true

require "jet_black"
require "support/environment_support"

RSpec.describe JetBlack::Session, "environment for #run_interactive" do
  include EnvironmentSupport

  it "allows overrides without affecting the current process" do
    with_environment("FOO" => "bar") do
      expect(ENV["FOO"]).to eq "bar"

      unmodified = run_interactive("printf $FOO", wait_for: "bar")
      expect(unmodified.stdout).to eq "bar"

      expect(ENV["FOO"]).to eq "bar"

      modifier = run_interactive("printf $FOO", wait_for: "123", env: { "FOO" => "123" })
      expect(modifier.stdout).to eq "123"

      expect(ENV["FOO"]).to eq "bar"
    end
  end

  it "allows overrides with symbol keys" do
    result = run_interactive("printf $FOO", wait_for: "bar", env: { FOO: "bar" })

    expect(result.stdout).to eq "bar"
  end

  it "allows overrides with non-string values" do
    result1 = run_interactive("printf $FOO", wait_for: "123", env: { "FOO" => 123 })
    expect(result1.stdout).to eq "123"

    result2 = run_interactive("printf $FOO", wait_for: "bar", env: { "FOO" => :bar })
    expect(result2.stdout).to eq "bar"
  end

  it "allows environment variables to be unset" do
    with_environment("FOO" => "bar") do
      result = run_interactive(%q(ruby -e 'puts ENV.key?("FOO")'), wait_for: "false", env: { "FOO" => nil })

      expect(result.stdout).to(include("false"), "$FOO should be unset")
    end
  end

  describe "clean_bundler_env option" do
    it "allows a clean environment without Bundler variables" do
      expect(ENV["BUNDLE_GEMFILE"]).to_not be_empty

      default_result = run_interactive("printf $BUNDLE_GEMFILE", wait_for: "Gemfile")
      expect(default_result.stdout).to eq ENV["BUNDLE_GEMFILE"]

      clean_result = run_interactive(
        %q(ruby -e 'puts ENV.key?("BUNDLE_GEMFILE"), "bye"'),
        wait_for: "bye",
        options: { clean_bundler_env: true },
      )
      expect(clean_result.stdout).to(include("false"), "$BUNDLE_GEMFILE should be unset")
    end

    it "allows the option to specified for the whole session" do
      session = described_class.new(options: { clean_bundler_env: true })

      clean_result = session.run_interactive(
        %q(ruby -e 'puts ENV.key?("BUNDLE_GEMFILE"), "bye"'),
      ) { |terminal| terminal.expect("bye") }

      expect(clean_result.stdout).to(include("false"), "$BUNDLE_GEMFILE should be unset")
    end

    it "allows the option to be overriden for a specific result" do
      session = described_class.new(options: { clean_bundler_env: true })

      result = session.run_interactive(
        %q(ruby -e 'puts ENV.key?("BUNDLE_GEMFILE"), "bye"'),
        options: { clean_bundler_env: false }
      ) { |terminal| terminal.expect("bye") }

      expect(result.stdout).to(include("true"), "$BUNDLE_GEMFILE should be set")
    end
  end

  def run_interactive(command, env: {}, options: {}, wait_for:)
    subject.run_interactive(command, env: env, options: options) do |terminal|
      terminal.expect(wait_for)
    end
  end
end
