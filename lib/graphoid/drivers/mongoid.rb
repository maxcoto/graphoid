# frozen_string_literal: true

module Graphoid
  # module that helps executing mongoid specific code
  module MongoidDriver
    class << self
      def through?(_type)
        false
      end

      def mongo_constants
        begin
          {
            many_to_many: Mongoid::Relations::Referenced::ManyToMany,
            has_many:     Mongoid::Relations::Referenced::Many,
            belongs_to:   Mongoid::Relations::Referenced::In,
            has_one:      Mongoid::Relations::Referenced::One,
            embeds_one:   Mongoid::Relations::Embedded::One,
            embeds_many:  Mongoid::Relations::Embedded::Many,
            embedded_in:  Mongoid::Relations::Embedded::In
          }
        rescue
          {
            many_to_many: Mongoid::Association::Referenced::HasAndBelongsToMany::Proxy,
            has_many:     Mongoid::Association::Referenced::HasMany::Proxy,
            belongs_to:   Mongoid::Association::Referenced::BelongsTo::Proxy,
            has_one:      Mongoid::Association::Referenced::HasOne::Proxy,
            embeds_one:   Mongoid::Association::Embedded::EmbedsOne::Proxy,
            embeds_many:  Mongoid::Association::Embedded::EmbedsMany::Proxy,
            embedded_in:  Mongoid::Association::Embedded::EmbeddedIn::Proxy
          }
        end
      end

      def has_and_belongs_to_many?(type)
        type == mongo_constants[:many_to_many]
      end

      def has_many?(type)
        type == mongo_constants[:has_many]
      end

      def belongs_to?(type)
        type == mongo_constants[:belongs_to]
        
      end

      def has_one?(type)
        type == mongo_constants[:has_one]
      end

      def embeds_one?(type)
        type == mongo_constants[:embeds_one]
      end

      def embeds_many?(type)
        type == mongo_constants[:embeds_many]
      end

      def embedded_in?(type)
        type == mongo_constants[:embedded_in]
      end

      def types_map
        {
          BSON::ObjectId => GraphQL::Types::ID,
          Mongoid::Boolean => GraphQL::Types::Boolean,
          # Graphoid::Upload => ApolloUploadServer::Upload,

          Boolean => GraphQL::Types::Boolean,
          Float => GraphQL::Types::Float,
          Integer => GraphQL::Types::Int,
          String => GraphQL::Types::String,
          Object => GraphQL::Types::String,
          Symbol => GraphQL::Types::String,

          DateTime => Graphoid::Scalars::DateTime,
          Time => Graphoid::Scalars::DateTime,
          Date => Graphoid::Scalars::DateTime,
          Array => Graphoid::Scalars::Array,
          Hash => Graphoid::Scalars::Hash
        }
      end

      def class_of(relation)
        {
          mongo_constants[:many_to_many]  => ManyToMany,
          mongo_constants[:has_many]      => HasMany,
          mongo_constants[:has_one]       => HasOne,
          mongo_constants[:belongs_to]    => BelongsTo,
          mongo_constants[:embeds_many]   => EmbedsMany,
          mongo_constants[:embeds_one]    => EmbedsOne,
          mongo_constants[:embedded_in]   => Relation
        }[relation.relation] || Relation
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

      def eager_load(selection, model, first = true)
        referenced_relations = [
          mongo_constants[:many_to_many],
          mongo_constants[:has_many],
          mongo_constants[:has_one],
          mongo_constants[:belongs_to]
        ]

        properties = first ? Utils.first_children_of(selection) : Utils.children_of(selection)
        inclusions = Utils.symbolize(properties)

        Relation.relations_of(model).each do |name, relation|
          name = relation.name
          next if inclusions.exclude?(name) || referenced_relations.exclude?(relation.relation)

          subselection = properties[name.to_s.camelize(:lower)]
          subproperties = Utils.children_of(subselection)
          subchildren = Utils.symbolize(subproperties)
          subrelations = relation.class_name.constantize.relations.values.map(&:name)

          if (subrelations & subchildren).empty?
            model = model.includes(name)
          else
            begin
              gem "mongoid_includes"
              model = model.includes(name, with: ->(instance) { eager_load(subselection, instance, false) })
            rescue Gem::LoadError
              model = model.includes(name)
            end
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

      def parse(attribute, value, operator, prefix = nil)
        field = attribute.name
        field = "#{prefix}.#{field}" if prefix
        parsed = {}
        case operator
        when 'gt', 'gte', 'lt', 'lte', 'in', 'nin'
          parsed[field.to_sym.send(operator)] = value
        when 'regex'
          parsed[field.to_sym] = Regexp.new(value.to_s, Regexp::IGNORECASE)
        when 'contains'
          parsed[field.to_sym] = Regexp.new(Regexp.quote(value.to_s), Regexp::IGNORECASE)
        when 'not'
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

        parsed = relate_embedded(scope, relation, value) if relation.embeds_one?

        parsed = relation.exec(scope, value) if relation.belongs_to?

        parsed = relation.exec(scope, value) if relation.has_one?

        parsed
      end

      def relate_many(scope, relation, value, operator)
        field_name = relation.inverse_name || scope.name.underscore
        target = Graphoid::Queries::Processor.execute(relation.klass, value).to_a

        if relation.embeds_many?
          # TODO: not implemented at all.
        end

        if relation.many_to_many?
          field_name = field_name.to_s.singularize + '_ids'
          ids = target.map(&field_name.to_sym)
          ids.flatten!.uniq!
        else
          field_name = field_name.to_s + '_id'
          ids = target.map(&field_name.to_sym)
        end

        parsed = {}
        if operator == 'none'
          parsed[:id.nin] = ids
        elsif operator == 'some'
          parsed[:id.in] = ids
        elsif operator == 'every'
          # missing implementation
        end
        parsed
      end
    end
  end
end
