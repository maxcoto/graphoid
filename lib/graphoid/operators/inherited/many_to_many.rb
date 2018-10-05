# frozen_string_literal: true

module Graphoid
  class ManyToMany < Relation
    def create(parent, values, grapho)
      values.each do |value|
        attributes = Attribute.correct(klass, value)
        attributes[:"#{grapho.name}_ids"] = [parent.id]
        klass.create!(attributes)
      end
    end
  end
end
