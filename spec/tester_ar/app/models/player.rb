# frozen_string_literal: true

class Player < ApplicationRecord
  has_many :contracts
  has_many :teams, through: :contracts

  include Graphoid::Queries
  include Graphoid::Mutations
end
