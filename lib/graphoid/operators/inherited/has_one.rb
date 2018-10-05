# frozen_string_literal: true

module Graphoid
  class HasOne < Relation
    def create(parent, value, grapho)
      attributes = Attribute.correct(klass, value)
      attributes[:"#{grapho.name}_id"] = parent.id
      klass.create!(attributes)
    end

    def exec(scope, value)
      field_name = inverse_name || scope.name.underscore
      ids = Graphoid::Queries::Processor.execute(klass, value).to_a.map(&"#{field_name}_id".to_sym)
      attribute = Attribute.new(name: 'id', type: nil)
      Graphoid.driver.parse(attribute, ids, 'in')
    end
  end
end
