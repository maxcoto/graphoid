# frozen_string_literal: true

module Graphoid
  class EmbedsMany < Relation
    def create(parent, values, _)
      values.each do |value|
        attributes = Attribute.correct(klass, value)
        parent.send(:"#{name}").create!(attributes)
      end
    end

    def exec(_scope, value)
      _hash = {}

      value.each do |key, _value|
        operation = Operation.new(klass, key, _value)
        parsed = Graphoid.driver.parse(operation.operand, operation.value, operation.operator, klass.to_s.underscore.pluralize)
        _hash.merge!(parsed)
      end

      _hash
    end
  end
end
