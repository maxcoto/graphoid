# frozen_string_literal: true

module Graphoid
  module Inputs
    LIST = {}

    class << self
      def generate(model)
        LIST[model] ||= GraphQL::InputObjectType.define do
          name = Utils.graphqlize(model.name)
          name("#{name}Input")
          description("Generated model input for #{name}")

          Attribute.fields_of(model).each do |field|
            next if field.name.start_with?('_')

            type = Graphoid::Mapper.convert(field)
            name = Utils.camelize(field.name)

            argument(name, type)
          end

          Relation.relations_of(model).each do |name, relation|
            relation_class = relation.class_name.safe_constantize
            next unless relation_class

            relation_input = LIST[relation_class]
            next unless relation_input

            name = Utils.camelize(relation.name)

            r = Relation.new(relation)
            if r.many?
              argument(name, -> { types[relation_input] })
            else
              argument(name, -> { relation_input })
            end
          end
        end
      end
    end
  end
end
