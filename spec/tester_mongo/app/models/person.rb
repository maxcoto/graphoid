class Person
  include Mongoid::Document
  include Mongoid::Timestamps
  include Graphoid::Queries
  include Graphoid::Mutations

  field :snake_case, type: String
  field :camelCase, type: String
  field :name, type: String

  belongs_to :account
end
