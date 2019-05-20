# frozen_string_literal: true

class Contract
  include Mongoid::Document
  include Mongoid::Timestamps

  include Graphoid::Queries
  include Graphoid::Mutations

  field :hello, type: String
  belongs_to :label
end
