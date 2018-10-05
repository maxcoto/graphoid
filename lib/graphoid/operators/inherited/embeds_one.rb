# frozen_string_literal: true

module Graphoid
  class EmbedsOne < Relation
    def create(parent, value, _)
      attrs = Attribute.correct(klass, value)
      parent.send(:"#{name}=", attrs)
    end

    def exec(_scope, value)
      _hash = {}

      value.each do |key, _value|
        operation = Operation.new(klass, key, _value)
        parsed = Graphoid.driver.parse(operation.operand, operation.value, operation.operator, klass.to_s.underscore)
        _hash.merge!(parsed)
      end

      _hash
    end
  end
end
