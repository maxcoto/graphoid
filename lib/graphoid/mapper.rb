# frozen_string_literal: true

module Graphoid
  module Mapper
    class << self
      def convert(field)
        return GraphQL::Types::ID if field.name.end_with?('id')

        Graphoid.driver.types_map[field.type] || GraphQL::Types::String
      end
    end
  end
end
