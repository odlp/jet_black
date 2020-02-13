# frozen_string_literal: true

require "jet_black"

RSpec.describe JetBlack do
  it "has a version number" do
    expect(JetBlack::VERSION).not_to be nil
  end

  it "allows the configuration to be reset" do
    JetBlack.configure do |config|
      config.fixture_directory = "foo"
      config.path_prefix = "baz"
    end

    JetBlack.reset!

    expect(JetBlack.configuration.fixture_directory).to be_nil
    expect(JetBlack.configuration.path_prefix).to be_nil
  end
end
