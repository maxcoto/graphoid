class Snake
  include Mongoid::Document
  include Mongoid::Timestamps
  include Graphoid::Queries
  include Graphoid::Mutations

  field :snake_case, type: Float
  field :camelCase, type: Integer
  field :name, type: String

  embedded_in :account
end
