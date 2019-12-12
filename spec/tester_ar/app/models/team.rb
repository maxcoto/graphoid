# frozen_string_literal: true

class Team < ApplicationRecord
  has_many :contracts
  has_many :players, through: :contracts

  include Graphoid::Queries
  include Graphoid::Mutations
end
