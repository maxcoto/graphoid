# frozen_string_literal: true

class Contract < ApplicationRecord
  belongs_to :player
  belongs_to :team

  include Graphoid::Queries
  include Graphoid::Mutations
end
