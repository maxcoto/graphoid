# frozen_string_literal: true

module Graphoid
  module Sorter
    LIST = {}
    @@enum_type = nil

    class << self
      def generate(model)
        LIST[model] ||= GraphQL::InputObjectType.define do
          name("#{Utils.graphqlize(model.name)}Sorter")
          description("Generated model Sorter for #{model.name}")

          Attribute.fields_of(model).each do |field|
            name = Utils.camelize(field.name)
            argument(name, Sorter.enum_type)
          end

          Relation.relations_of(model).each do |name, relation|
            relation_class = relation.class_name.safe_constantize
            next unless relation_class

            relation_order = LIST[relation_class]
            next unless relation_order

            relation_name = Utils.camelize(name)

            argument(relation_name, relation_order)
          end
        end
      end

      def enum_type
        @@enum_type ||= GraphQL::EnumType.define do
          name 'SorterType'

          value 'ASC', 'Ascendent'
          value 'DESC', 'Descendent'
        end
      end
    end
  end
end
