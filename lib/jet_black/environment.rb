# frozen_string_literal: true

module JetBlack
  class Environment
    def initialize(raw_env)
      @raw_env = raw_env.dup
    end

    def to_h
      apply_path_prefix(stringify_env(raw_env))
    end

    private

    attr_reader :raw_env

    def stringify_env(env)
      env.each_with_object({}) do |(key, value), memo|
        memo[key.to_s] = value&.to_s
      end
    end

    def apply_path_prefix(env)
      if path_prefix&.empty?
        env
      else
        env["PATH"] = [path_prefix, ENV["PATH"]].join(File::PATH_SEPARATOR)
        env
      end
    end

    def path_prefix
      JetBlack.configuration.path_prefix
    end
  end
end
