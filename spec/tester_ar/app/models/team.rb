# frozen_string_literal: true

class Team < ApplicationRecord
  include Graphoid::Queries
  include Graphoid::Mutations

  has_many :contracts
  has_many :players, through: :contracts
end
