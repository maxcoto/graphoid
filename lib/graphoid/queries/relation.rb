module Graphoid

  class Relation
    attr_reader :name, :klass, :type, :inverse_name

    def initialize(relation)
      @name = relation.name.to_s
      @camel_name = Utils.camelize(@name)
      @inverse_name = Graphoid.driver.inverse_name_of(relation)
      @klass = relation.class_name.constantize
      @type = Graphoid.driver.relation_type(relation)
    end

    [:has_and_belongs_to_many, :through, :has_many, :belongs_to, :has_one, :embeds_one, :embeds_many, :embedded_in].each do |type|
      type = :"#{type}?"
      define_method type do
        Graphoid.driver.send(type, @type)
      end
    end

    def relation?
      true
    end

    def one?
      belongs_to? || has_one? || embeds_one?
    end

    def many?
      # TODO: "through" can be one or many, we only support many at the moment.
      has_many? || has_and_belongs_to_many? || through? || embeds_many?
    end

    def belongs?
      belongs_to? || embedded_in?
    end

    def many_to_many?
      has_and_belongs_to_many? || through?
    end

    def embedded?
      embeds_one? || embeds_many? || embedded_in?
    end

    def resolve(o)
      if one?
        return Graphoid.driver.relate_one(o.scope, o.operand, o.value)
      end

      if many?
        return Graphoid.driver.relate_many(o.scope, o.operand, o.value, o.operator)
      end
    end

    class << self
      def relations_of(model)
        # return a list of relation objects
        # Graphoid.driver.relations_of(model).map { |_, relation| Relation.new(relation) }
        Graphoid.driver.relations_of(model)
      end
    end
  end
end
