# frozen_string_literal: true

module Graphoid
  class Grapho
    attr_reader :name, :plural, :camel_name
    attr_reader :type, :filter, :order, :input

    def initialize(model)
      build_naming(model)

      @type   = Graphoid::Types.generate(model)
      @order  = Graphoid::Sorter.generate(model)
      @input  = Graphoid::Inputs.generate(model)
      @filter = Graphoid::Filters.generate(model)
    end

    private

    def build_naming(model)
      @camel_name = Utils.graphqlize(model.name)
      @name = @camel_name.underscore
      @plural = @name.pluralize
    end
  end
end
