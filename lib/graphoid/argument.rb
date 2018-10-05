# frozen_string_literal: true

module Graphoid
  # A module that defines the query packet arguments
  module Argument
    class << self
      def query_many(field, filter, order, required = {})
        field.argument :where, filter, required
        field.argument :order, order, required
        field.argument :limit, GraphQL::Types::Int, required
        field.argument :skip,  GraphQL::Types::Int, required
      end
    end
  end
end
