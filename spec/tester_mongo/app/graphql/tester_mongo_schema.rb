# frozen_string_literal: true

class TesterMongoSchema < GraphQL::Schema
  mutation(Types::MutationType)
  query(Types::QueryType)
end
