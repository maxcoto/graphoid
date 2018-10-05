class Player < ApplicationRecord
  include Graphoid::Queries
  include Graphoid::Mutations

  has_many :contracts
  has_many :teams, through: :contracts
end
