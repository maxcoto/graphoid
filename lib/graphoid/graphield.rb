# frozen_string_literal: true

module Graphoid
  module Graphield
    extend ActiveSupport::Concern

    included do
      @graphields = []
      @forbidden = {}

      class << self
        def graphield(name, type)
          @graphields << Graphoid::Attribute.new(name: name.to_s, type: type)
        end

        def graphorbid(field, *actions)
          @forbidden[field] = actions
        end

        attr_reader :graphields

        def graphfiles
          @graphields.select { |field| field.type == Graphoid::Upload }
        end

        def forbidden_fields
          @forbidden
        end
      end
    end
  end
end
