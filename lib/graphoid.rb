require 'graphoid/queries/attribute'
require 'graphoid/queries/relation'

require 'graphoid/utils'
require 'graphoid/grapho'
require 'graphoid/mapper'
require 'graphoid/config'
require 'graphoid/scalars'
require 'graphoid/argument'
require 'graphoid/graphield'

require 'graphoid/queries/queries'
require 'graphoid/queries/processor'
require 'graphoid/queries/operation'

require 'graphoid/mutations/create'
require 'graphoid/mutations/update'
require 'graphoid/mutations/delete'
require 'graphoid/mutations/processor'
require 'graphoid/mutations/structure'

require 'graphoid/drivers/mongoid'
require 'graphoid/drivers/active_record'

require 'graphoid/definitions/types'
require 'graphoid/definitions/orders'
require 'graphoid/definitions/filters'
require 'graphoid/definitions/inputs'

module Graphoid
  @@graphs = {}

  class << self
    attr_accessor :driver

    def initialize
      Graphoid.driver = configuration&.driver
      Rails.application.eager_load!
      Graphoid::Scalars.generate
    end

    def build(model, action = nil)
      @@graphs[model] ||= Graphoid::Grapho.new(model)
    end

    def driver=(driver)
      @driver = driver == :active_record ? ActiveRecordDriver : MongoidDriver
    end
  end
end
