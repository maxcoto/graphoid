# frozen_string_literal: true

module Graphoid
  module ActiveRecordDriver
    class << self
      def through?(type)
        type == ActiveRecord::Reflection::ThroughReflection
      end

      def has_and_belongs_to_many?(type)
        type == ActiveRecord::Reflection::HasAndBelongsToManyReflection
      end

      def has_many?(type)
        type == ActiveRecord::Reflection::HasManyReflection
      end

      def belongs_to?(type)
        type == ActiveRecord::Reflection::BelongsToReflection
      end

      def has_one?(type)
        type == ActiveRecord::Reflection::HasOneReflection
      end

      def embeds_one?(_type)
        false
      end

      def embeds_many?(_type)
        false
      end

      def embedded_in?(_type)
        false
      end

      def types_map
        {
          binary: GraphQL::Types::Boolean,
          boolean: GraphQL::Types::Boolean,
          float: GraphQL::Types::Float,
          integer: GraphQL::Types::Int,
          string: GraphQL::Types::String,

          datetime: Graphoid::Scalars::DateTime,
          date: Graphoid::Scalars::DateTime,
          time: Graphoid::Scalars::DateTime,
          timestamp: Graphoid::Scalars::DateTime,
          text: Graphoid::Scalars::Text,
          bigint: Graphoid::Scalars::BigInt,
          decimal: Graphoid::Scalars::Decimal
        }
      end

      def class_of(relation)
        {
          ActiveRecord::Reflection::HasAndBelongsToManyReflection => ManyToMany,
          ActiveRecord::Reflection::BelongsToReflection => BelongsTo,
          ActiveRecord::Reflection::ThroughReflection => ManyToMany,
          ActiveRecord::Reflection::HasManyReflection => HasMany,
          ActiveRecord::Reflection::HasOneReflection => HasOne
        }[relation.class] || Relation
      end

      def inverse_name_of(relation)
        relation.inverse_of&.class_name&.underscore
      end

      def fields_of(model)
        begin 
          model.columns
        rescue
          []
        end
      end

      def relations_of(model)
        model.reflections
      end

      def skip(result, skip)
        result.offset(skip)
      end

      def relation_type(relation)
        relation.class
      end

      def generate_array(nodes)
        include_array = []
        nodes.each do |node|
          children = node.selections.select!{ |n| !n.selections.empty? }

          if children.empty?
            include_array.push(node.name.to_sym)
          else
            include_array.push(node.name.to_sym => generate_array(children))
          end
        end

        include_array
      end

      def eager_load(selection, model)
        nodes = selection.ast_node.selections.first.selections
        nodes.select!{ |n| !n.selections.empty? }
        include_array = generate_array(nodes)
        include_array.empty? ? model : model.includes(*include_array)
      end

      def execute_and(scope, parsed)
        scope.where(parsed)
      end

      def execute_or(scope, list)
        list.map! do |object|
          Graphoid::Queries::Processor.execute(scope, object)
        end
        list.reduce(:or)
      end

      def parse(attribute, value, operator)
        field = attribute.name
        case operator
        when 'not'
          parsed = ["#{field} != ?", value]
          parsed = ["#{field} not like ?", value.to_s] if attribute.type == :string
          parsed = ["#{field} is not null"] if value.nil?
        when 'contains', 'regex'
          parsed = ["#{field} like ?", "%#{value}%"]
        when 'gt', 'gte', 'lt', 'lte', 'not', 'in', 'nin'
          operator = { gt: '>', gte: '>=', lt: '<', lte: '<=', in: 'in', nin: 'not in' }[operator.to_sym]
          parsed = ["#{field} #{operator} (?)", value]
        else
          parsed = ["#{field} = ?", value]
        end
        parsed
      end

      # TODO: fix this as it is unused
      def relate_through(scope, relation, value)
        # if relation.has_one_through?
        #   ids = Graphoid::Queries::Processor.execute(relation.klass, value).to_a.map(&:id)
        #   through = relation.source.options[:through].to_s.camelize.constantize
        #   ids = through.where(id: ids)
        #   ids = Graphoid::Queries::Processor.execute(relation.klass, value).to_a.map(&:id)
        #   parsed = *["#{field.underscore}_id in (?)", ids]
        # end
      end

      def relate_many(scope, relation, value, operator)
        parsed = {}
        field_name = relation.inverse_name || scope.name.underscore
        target = Graphoid::Queries::Processor.execute(relation.klass, value).to_a

        if relation.many_to_many?
          field_name = field_name.to_s.singularize + '_ids'
          ids = target.map(&field_name.to_sym)
          ids.flatten!.uniq!
        else
          field_name = :"#{field_name}_id"
          ids = target.map(&field_name)
        end

        if operator == 'none'
          parsed = ['id not in (?)', ids] if ids.present?
        elsif operator == 'some'
          parsed = ['id in (?)', ids]
        elsif operator == 'every'

          # the following process is a SQL division
          # the amount of queries it executes is on per row
          # it is the same than doing an iteration process
          # that iteration process would work in mongoid too

          # TODO: check and fix this query for many to many relations

          plural_name = relation.name.pluralize
          conditions = value.map do |_key, _value|
            operation = Operation.new(relation.klass, _key, _value)
            parsed = parse(operation.operand, operation.value, operation.operator)
            val = parsed.last.is_a?(String) ? "'#{parsed.last}'" : parsed.last
            parsed = parsed.first.sub('?', val)
            " AND #{parsed}"
          end.join

          query = "
                    SELECT count(id) as total, #{field_name}
                    FROM #{plural_name} A
                    GROUP BY #{field_name}
                    HAVING total = (
                      SELECT count(id)
                      FROM #{plural_name} B
                      WHERE B.#{field_name} = A.#{field_name}
                      #{conditions}
                    )
                  "
          result = ActiveRecord::Base.connection.execute(query)
          ids = result.map { |row| row[field_name.to_s] }

          parsed = ['id in (?)', ids]
        end

        parsed
      end
    end
  end
end
