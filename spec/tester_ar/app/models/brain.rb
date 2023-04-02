# frozen_string_literal: true

class Brain < ApplicationRecord
  belongs_to :person
  
  include Graphoid::Queries
  include Graphoid::Mutations
end
