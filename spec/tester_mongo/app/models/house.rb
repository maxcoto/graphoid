# frozen_string_literal: true

class House
  include Mongoid::Document
  include Mongoid::Timestamps

  include Graphoid::Queries
  include Graphoid::Mutations

  field :name, type: String

  has_many :accounts, dependent: :destroy
end
