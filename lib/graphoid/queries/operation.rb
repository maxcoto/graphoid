module Graphoid
  class Operation
    attr_reader :scope, :operand, :operator, :value

    def initialize(scope, key, value)
      @scope = scope
      @operator = nil
      @operand = key
      @value = value

      match = key.match(/^(.+)_(.+)$/)
      @operand, @operator = match[1..2] if match
      @operand = build_operand(@scope, @operand) || @operand
    end

    def resolve
      @operand.resolve(self)
    end

    private

    def build_operand(model, key)
      fields = Attribute.fields_of(model)

      field = fields.find { |f| f.name == key }
      return Attribute.new(name: key, type: field.type) if field

      field = fields.find { |f| f.name == key.underscore }
      return Attribute.new(name: key.underscore, type: field.type) if field

      relations = model.reflect_on_all_associations

      relation = relations.find { |r| r.name == key.to_sym }
      return Relation.new(relation) if relation

      relation = relations.find { |r| r.name == key.underscore.to_sym }
      return Relation.new(relation) if relation
    end
  end
end
