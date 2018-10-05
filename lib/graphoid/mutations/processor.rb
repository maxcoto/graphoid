# frozen_string_literal: true

module Graphoid
  module Mutations
    module Processor
      def self.execute(model, grapho, data, user)
        root_object = []
        operations = []
        data.each { |key, value| operations << Operation.new(model, key, value) }

        operations.each do |operation|
          item = operation.operand.precreate(operation.value)
          root_object << item if item.present?
        end

        root_object = root_object.reduce({}, :merge)

        fieldnames = Attribute.fieldnames_of(model)
        root_object['created_by_id'] = user.id if fieldnames.include?('created_by_id')
        root_object['updated_by_id'] = user.id if fieldnames.include?('updated_by_id')

        sanitized = Attribute.correct(model, root_object)
        root = model.create!(sanitized)

        operations.each do |operation|
          operation.operand.create(root, operation.value, grapho)
        end

        root.reload
      end
    end
  end
end
