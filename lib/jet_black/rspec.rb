require "rspec/core"
require_relative "rspec/matchers"

module JetBlack
  module RSpec
  end
end

RSpec.configure do |config|
  config.define_derived_metadata(file_path: %r{/spec/black_box/}) do |metadata|
    metadata[:type] = :black_box
  end

  config.include JetBlack::RSpec::Matchers, type: :black_box
end
