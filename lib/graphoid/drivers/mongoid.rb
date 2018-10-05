module Graphoid
  module MongoidDriver
    class << self
      def through?(type)
        false
      end

      def has_and_belongs_to_many?(type)
        type == Mongoid::Relations::Referenced::ManyToMany
      end

      def has_many?(type)
        type == Mongoid::Relations::Referenced::Many
      end

      def belongs_to?(type)
        type == Mongoid::Relations::Referenced::In
      end

      def has_one?(type)
        type == Mongoid::Relations::Referenced::One
      end

      def embeds_one?(type)
        type == Mongoid::Relations::Embedded::One
      end

      def embeds_many?(type)
        type == Mongoid::Relations::Embedded::Many
      end

      def embedded_in?(type)
        type == Mongoid::Relations::Embedded::In
      end

      def types_map
        {
          BSON::ObjectId   => GraphQL::Types::ID,
          Mongoid::Boolean => GraphQL::Types::Boolean,
          Graphoid::Upload    => ApolloUploadServer::Upload,

          Boolean  => GraphQL::Types::Boolean,
          Float    => GraphQL::Types::Float,
          Integer  => GraphQL::Types::Int,
          String   => GraphQL::Types::String,
          Object   => GraphQL::Types::String,
          Symbol   => GraphQL::Types::String,

          DateTime => Graphoid::Scalars::DateTime,
          Time     => Graphoid::Scalars::DateTime,
          Date     => Graphoid::Scalars::DateTime,
          Array    => Graphoid::Scalars::Array,
          Hash     => Graphoid::Scalars::Hash
        }
      end

      def inverse_name_of(relation)
        relation.inverse_of
      end

      def fields_of(model)
        model.respond_to?(:fields) ? model.fields.values : []
      end

      def relations_of(model)
        model.relations
      end

      def skip(result, skip)
        result.skip(skip)
      end

      def relation_type(relation)
        relation.relation
      end

      def eager_load(selection, model)
        referenced_relations = [
          Mongoid::Relations::Referenced::ManyToMany,
          Mongoid::Relations::Referenced::Many,
          Mongoid::Relations::Referenced::One,
          Mongoid::Relations::Referenced::In
        ]

        properties = Graphoid::Queries::Processor.children_of(selection)
        inclusions = Utils.symbolize(properties)

        Relation.relations_of(model).each do |name, relation|
          name = relation.name
          next if inclusions.exclude?(name) || referenced_relations.exclude?(association.relation)

          subselection = properties[name.to_s.camelize(:lower)]
          children = Utils.symbolize(Graphoid::Queries::Processor.children_of(subselection))
          relations = relation.class_name.constantize.reflections.values.map(&:name)

          if (relations & children).empty?
            model = model.includes(name)
          else
            model = model.includes(name, with: -> (instance) { Graphoid::Queries::Processor.eager_load(subselection, instance) })
          end
        end

        model
      end

      def execute_and(scope, parsed)
        scope.and(parsed)
      end

      def execute_or(scope, list)
        list.map! do |object|
          Graphoid::Queries::Processor.execute(scope, object).selector
        end
        scope.any_of(list)
      end

      def parse(attribute, value, operator)
        field = attribute.name
        parsed = {}
        case operator
        when "gt", "gte", "lt", "lte", "in", "nin"
          parsed[field.to_sym.send(operator)] = value
        when "regex"
          parsed[field.to_sym] = Regexp.new(value.to_s, Regexp::IGNORECASE)
        when "contains"
          parsed[field.to_sym] = Regexp.new(Regexp.quote(value.to_s), Regexp::IGNORECASE)
        when "not"
          if value.present? && !value.is_a?(Numeric)
            parsed[field.to_sym.send(operator)] = Regexp.new(Regexp.quote(value.to_s), Regexp::IGNORECASE)
          else
            parsed[field.to_sym.send(:nin)] = [value]
          end
        else
          parsed[field.to_sym] = value
        end
        parsed
      end

      def relate_embedded(scope, relation, filters)
        # TODO: this way of fetching this is not recursive as the regular fields
        # because the structure of the query is embeeded.field = value
        # we need more brain cells on this problem because it does not allow
        # to filter things using OR/AND
        parsed = {}
        filters.each do |key, value|
          operation = Operation.new(scope, key, value)
          attribute = OpenStruct.new(name: "#{relation.name}.#{operation.operand}")
          obj = parse(attribute, value, operation.operator).first
          parsed[obj[0]] = obj[1]
        end
        parsed
      end

      def relate_one(scope, relation, value)
        field = relation.name
        parsed = {}

        if relation.embeds_one?
          parsed = relate_embedded(scope, relation, value)
        end

        if relation.belongs_to?
          ids = Graphoid::Queries::Processor.execute(relation.klass, value).to_a.map(&:id)
          parsed["#{field.underscore}_id".to_sym.send(:in)] = ids
        end

        if relation.has_one?
          field_name = relation.inverse_name || scope.name.underscore
          ids = Graphoid::Queries::Processor.execute(relation.klass, value).to_a.map(&("#{field_name}_id".to_sym))
          parsed[:id.in] = ids
        end

        parsed
      end

      def relate_many(scope, relation, value, operator)
        field_name = relation.inverse_name || scope.name.underscore
        target = Graphoid::Queries::Processor.execute(relation.klass, value).to_a

        if relation.embeds_many?
          # TODO: not implemented at all.
        end

        if relation.many_to_many?
          field_name = field_name.to_s.singularize + "_ids"
          ids = target.map(&(field_name.to_sym))
          ids.flatten!.uniq!
        else
          field_name = field_name.to_s + "_id"
          ids = target.map(&(field_name.to_sym))
        end

        parsed = {}
        if operator == "none"
          parsed[:id.nin] = ids
        elsif operator == "some"
          parsed[:id.in] = ids
        elsif operator == "every"
          # missing implementation
        end
        parsed
      end
    end
  end
end
