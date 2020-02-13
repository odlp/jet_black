# frozen_string_literal: true

require "rspec/expectations"

module JetBlack
  module RSpec
    module Matchers
      extend ::RSpec::Matchers::DSL

      def have_stdout(expected)
        HaveStdout.new(expected)
      end

      def have_stderr(expected)
        HaveStderr.new(expected)
      end

      matcher(:have_no_stdout) do
        match { |result| result.stdout.empty? }

        failure_message do |result|
          <<~MSG
            expected command to have no stdout output. Got:
            ---
            #{result.stdout}
          MSG
        end
      end

      matcher(:have_no_stderr) do
        match { |result| result.stderr.empty? }

        failure_message do |result|
          <<~MSG
            expected command to have no stderr output. Got:
            ---
            #{result.stderr}
          MSG
        end
      end

      class HaveStdout < ::RSpec::Matchers::BuiltIn::Match
        def matches?(actual)
          super(actual.stdout)
        end
      end

      class HaveStderr < ::RSpec::Matchers::BuiltIn::Match
        def matches?(actual)
          super(actual.stderr)
        end
      end
    end
  end
end
