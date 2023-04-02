# frozen_string_literal: true

module Graphoid
  module Queries
    extend ActiveSupport::Concern

    included do
      def self.graphoid?() true end

      Graphoid.initialize
      model = self
      grapho = Graphoid.build(model)
      query_type = ::Types::QueryType

      query_type.field name: grapho.name, type: grapho.type, null: true do
        argument :id, GraphQL::Types::ID, required: false
        argument :where, grapho.filter, required: false
      end

      query_type.field name: grapho.plural, type: [grapho.type], null: true do
        Graphoid::Argument.query_many(self, grapho.filter, grapho.order, required: false)
      end

      query_type.field name: "x_meta_#{grapho.plural}", type: Graphoid::Types::Meta, null: true do
        Graphoid::Argument.query_many(self, grapho.filter, grapho.order, required: false)
      end

      query_type.class_eval do
        define_method :"#{grapho.name}" do |id: nil, where: nil|
          begin
            return model.find(id) if id
            Processor.execute(model, where.to_h).first
          rescue Exception => ex
            GraphQL::ExecutionError.new(ex.message)
          end
        end
      end

      query_type.class_eval do
        define_method :"#{grapho.plural}" do |where: nil, order: nil, limit: nil, skip: nil|
          begin
            model = Graphoid.driver.eager_load(context.irep_node, model)
            result = Processor.execute(model, where.to_h)
            order = Processor.parse_order(model, order.to_h)
            result = result.order(order).limit(limit)
            Graphoid.driver.skip(result, skip)
          rescue Exception => ex
            GraphQL::ExecutionError.new(ex.message)
          end
        end

        alias_method :"x_meta_#{grapho.plural}", :"#{grapho.plural}"
      end
    end
  end
end
