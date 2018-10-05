module Graphoid
  class << self
    attr_accessor :configuration

    def configure
      self.configuration ||= Configuration.new
      yield(configuration)
      Graphoid.initialize
    end
  end

  class Configuration
    attr_accessor :driver

    def initialize
      @driver = :active_record
    end
  end
end
