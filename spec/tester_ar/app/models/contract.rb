# frozen_string_literal: true

class Contract < ApplicationRecord
  include Graphoid::Queries
  include Graphoid::Mutations

  belongs_to :player
  belongs_to :team
end
