# frozen_string_literal: true

module Graphoid
  module Mutations
    module Create
      extend ActiveSupport::Concern

      included do
        def self.graphoid?() true end

        Graphoid.initialize
        model = self
        grapho = Graphoid.build(model)
        type = ::Types::MutationType

        name = "create_#{grapho.name}"
        plural_name = name.pluralize

        type.field(name: name, type: grapho.type, null: true) do
          argument(:data, grapho.input, required: false)
        end

        type.field(name: plural_name, type: [grapho.type], null: true) do
          argument(:data, [grapho.input], required: false)
        end

        type.class_eval do
          define_method :"#{name}" do |data: {}|
            begin
              user = context[:current_user]
              Graphoid::Mutations::Processor.execute(model, grapho, data, user)
            rescue Exception => ex
              GraphQL::ExecutionError.new(ex.message)
            end
          end
        end

        type.class_eval do
          define_method :"#{plural_name}" do |data: []|
            begin 
              user = context[:current_user]
              result = []
              data.each { |d| result << Graphoid::Mutations::Processor.execute(model, grapho, d, user) }
              result
            rescue Exception => ex
              GraphQL::ExecutionError.new(ex.message)
            end
          end
        end
      end
    end
  end
end
