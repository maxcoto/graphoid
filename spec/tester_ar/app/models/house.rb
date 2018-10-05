class House < ApplicationRecord
  include Graphoid::Queries
  include Graphoid::Mutations

  has_many :accounts
end
