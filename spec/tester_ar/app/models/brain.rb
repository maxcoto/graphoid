# frozen_string_literal: true

class Brain < ApplicationRecord
  include Graphoid::Queries
  include Graphoid::Mutations

  belongs_to :person
end
