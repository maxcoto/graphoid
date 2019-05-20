# frozen_string_literal: true

class Label
  include Mongoid::Document
  include Mongoid::Timestamps
  include Graphoid::Queries
  include Graphoid::Mutations

  field :snake_case, type: String
  field :camelCase, type: String
  field :name, type: String
  field :amount, type: Float

  belongs_to :account
  has_many :contracts
end
