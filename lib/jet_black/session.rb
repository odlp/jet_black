# frozen_string_literal: true

require "tmpdir"

module JetBlack
  class Session
    def directory
      @_directory ||= Dir.mktmpdir("jet_black")
    end
  end
end
