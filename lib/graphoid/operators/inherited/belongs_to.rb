# frozen_string_literal: true

module Graphoid
  class BelongsTo < Relation
    def precreate(value)
      sanitized = Attribute.correct(klass, value)
      foreign_id = klass.create!(sanitized).id
      { :"#{name}_id" => foreign_id }
    end

    def exec(_, value)
      ids = Graphoid::Queries::Processor.execute(klass, value).to_a.map(&:id)
      attribute = Attribute.new(name: "#{name.underscore}_id", type: nil)
      Graphoid.driver.parse(attribute, ids, 'in')
    end
  end
end
