# frozen_string_literal: true

class Label < ApplicationRecord
  belongs_to :account
  
  include Graphoid::Queries
  include Graphoid::Mutations
  include Graphoid::Graphield
end
