# frozen_string_literal: true

PROJECT_ROOT = File.expand_path("..", __dir__).freeze
SPEC_ROOT = File.expand_path(__dir__).freeze

enable_coverage = ENV.key?("ENABLE_COVERAGE")
enable_coveralls = enable_coverage && ENV.key?("COVERALLS_REPO_TOKEN")

if enable_coverage
  require "simplecov"
  SimpleCov.start do
    add_filter "/spec/"
  end
end

if enable_coveralls
  require "coveralls"
  Coveralls.wear!
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.disable_monkey_patching!
  config.warnings = true
  config.order = :random
  Kernel.srand config.seed
end
