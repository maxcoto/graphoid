# frozen_string_literal: true

class TesterArSchema < GraphQL::Schema
  mutation(Types::MutationType)
  query(Types::QueryType)
end
