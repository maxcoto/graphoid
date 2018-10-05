module Graphoid
  module Mutations
    module Processor
      def self.execute(model, grapho, data, user)
        root_object = {}
        delayed_objects = []

        data.each do |key, value|
          operation = Operation.new(model, key, value)
          operand = operation.operand

          if operand.relation?
            if operand.belongs?
              if operand.embedded?
                # el boludo no lo resolvio
              else
                sanitized = Attribute.correct(operand.klass, value)
                foreign_id = operand.klass.create!(sanitized).id
                root_object[:"#{operand.name}_id"] = foreign_id
              end
            else
              delayed_objects << operation
            end
          else
            root_object[:"#{operand.name}"] = value
          end
        end

        fieldnames = Attribute.fieldnames_of(model)
        root_object['created_by_id'] = user.id if fieldnames.include?('created_by_id')
        root_object['updated_by_id'] = user.id if fieldnames.include?('updated_by_id')

        sanitized = Attribute.correct(model, root_object)
        root = model.create!(sanitized)

        delayed_objects.each do |operation|
          relation = operation.operand

          if relation.embedded?
            if relation.embeds_one?
              attrs = Attribute.correct(relation.klass, operation.value)
              root.send(:"#{relation.name}=", attrs)
            else # means embeds many
              operation.value.each do |attrs|
                attrs = Attribute.correct(relation.klass, attrs)
                root.send(:"#{relation.name}").create!(attrs)
              end
            end
            # necessary ??
            root.save!
          else
            if relation.has_many? || relation.many_to_many?
              operation.value.each do |attrs|
                attrs = Attribute.correct(relation.klass, attrs)
                if relation.many_to_many?
                  attrs[:"#{grapho.name}_ids"] = [root.id]
                else
                  attrs[:"#{grapho.name}_id"] = root.id
                end
                relation.klass.create!(attrs)
              end
            else
              attrs = Attribute.correct(relation.klass, operation.value)
              attrs[:"#{grapho.name}_id"] = root.id
              relation.klass.create!(attrs)
            end
          end
        end

        root.reload
      end
    end
  end
end
