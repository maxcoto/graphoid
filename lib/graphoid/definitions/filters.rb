module Graphoid
  module Filters

    LIST = {}

    class << self
      def generate(model)
        LIST[model] ||= GraphQL::InputObjectType.define do
          name("#{Utils.graphqlize(model.name)}Filter")
          description("Generated model filter for #{model.name}")

          Attribute.fields_of(model).each do |field|
            type = Graphoid::Mapper.convert(field)
            name = Utils.camelize(field.name)

            argument name, type

            m = LIST[model]
            argument(:OR,  -> { types[m] })
            argument(:AND, -> { types[m] })

            operators = ["lt", "lte", "gt", "gte", "contains", "not"]
            operators.push("regex") if Graphoid.configuration.driver == :mongoid

            operators.each do |suffix|
              argument "#{name}_#{suffix}", type
            end

            ["in", "nin"].each do |suffix|
              argument "#{name}_#{suffix}", types[type]
            end
          end

          Relation.relations_of(model).each do |name, relation|
            relation_class = relation.class_name.safe_constantize
            next unless relation_class

            relation_filter = LIST[relation_class]
            next unless relation_filter

            relation_name = Utils.camelize(name)

            if Relation.new(relation).many?
              ["some", "none", "every"].each do |suffix|
                argument "#{relation_name}_#{suffix}", relation_filter
              end
            else
              argument "#{relation_name}", relation_filter
            end
          end

        end
      end

    end
  end
end
