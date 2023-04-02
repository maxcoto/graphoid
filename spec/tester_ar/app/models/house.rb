# frozen_string_literal: true

class House < ApplicationRecord
  has_many :accounts
  
  include Graphoid::Queries
  include Graphoid::Mutations
end
