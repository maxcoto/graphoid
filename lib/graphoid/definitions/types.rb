# frozen_string_literal: true

module Graphoid
  module Types
    LIST = {}
    ENUMS = {}

    class << self
      def generate(model)
        Graphoid::Types::Meta ||= GraphQL::ObjectType.define do
          name('xMeta')
          description('xMeta Type')
          field('count', types.Int)
        end

        LIST[model] ||= GraphQL::ObjectType.define do
          name = Utils.graphqlize(model.name)
          name("#{name}Type")
          description("Generated model type for #{name}")

          Attribute.fields_of(model).each do |attribute|
            type = Graphoid::Mapper.convert(attribute)
            name = Utils.camelize(attribute.name)
            field(name, type)

            model.class_eval do
              if attribute.name.include?('_')
                define_method :"#{Utils.camelize(attribute.name)}" do
                  method_name = attribute.name.to_s
                  self[method_name] || send(method_name)
                end
              end
            end
          end

          Relation.relations_of(model).each do |_, relation|
            message = "in model #{model.name}: skipping relation #{relation.class_name}"

            relation_class = relation.class_name.safe_constantize
            unless relation_class
              warn "Graphoid: warning: #{message} because the model name is not valid" if ENV['DEBUG']
              next
            end

            unless relation_class.respond_to?(:graphoid?)
              warn "Graphoid: warning: #{message} because it was not found as a model" if ENV['DEBUG']
              next
            end

            name = Utils.camelize(relation.name)

            model.class_eval do
              if relation.name.to_s.include?('_')
                define_method :"#{name}" do
                  send(relation.name)
                end
              end
            end

            if Relation.new(relation).many?
              plural_name = name.pluralize

              field plural_name do
                type -> { types[LIST[relation_class]] }

                argument :where, -> { Graphoid::Filters::LIST[relation_class] }
                argument :order, -> { Graphoid::Sorter::LIST[relation_class] }
                argument :limit, GraphQL::Types::Int
                argument :skip,  GraphQL::Types::Int

                Graphoid::Types.resolve_many(self, relation_class, relation)
              end

              field "x_meta_#{plural_name}" do
                type Graphoid::Types::Meta

                argument :where, -> { Graphoid::Filters::LIST[relation_class] }
                argument :order, -> { Graphoid::Sorter::LIST[relation_class] }
                argument :limit, GraphQL::Types::Int
                argument :skip,  GraphQL::Types::Int

                Graphoid::Types.resolve_many(self, relation_class, relation)
              end
            else
              field name do
                type -> { LIST[relation_class] }
                argument :where, -> { Graphoid::Filters::LIST[relation_class] }
                Graphoid::Types.resolve_one(self, relation_class, relation)
              end
            end
          end
        end
      end

      def resolve_one(field, model, association)
        field.resolve lambda { |obj, args, _ctx|
          filter = args['where'].to_h
          result = obj.send(association.name)
          processor = Graphoid::Queries::Processor
          if filter.present? && result
            result = processor.execute(model.where(id: result.id), filter).first
          end
          result
        }
      end

      def resolve_many(field, _model, association)
        field.resolve lambda { |obj, args, _ctx|
          filter = args['where'].to_h
          order = args['order'].to_h
          limit = args['limit']
          skip = args['skip']

          processor = Graphoid::Queries::Processor

          result = obj.send(association.name)
          result = processor.execute(result, filter) if filter.present?

          if order.present?
            order = processor.parse_order(obj.send(association.name), order)
            result = result.order(order)
          end

          result = result.limit(limit) if limit.present?
          result = result.skip(skip) if skip.present?

          result
        }
      end
    end
  end
end
