# frozen_string_literal: true

module Graphoid
  @graphs = {}

  class << self
    attr_reader :driver

    def initialize
      Graphoid.driver ||= configuration&.driver
      Graphoid::Scalars.generate
    end

    def build(model, _action = nil)
      @graphs[model] ||= Graphoid::Grapho.new(model)
    end

    def driver=(driver)
      @driver = driver == :active_record ? ActiveRecordDriver : MongoidDriver
    end
  end
end
