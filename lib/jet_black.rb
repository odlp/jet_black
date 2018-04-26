require "jet_black/configuration"
require "jet_black/session"
require "jet_black/version"

module JetBlack
  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield configuration if block_given?
  end
end
