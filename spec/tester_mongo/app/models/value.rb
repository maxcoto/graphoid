# frozen_string_literal: true

class Value
  include Mongoid::Document
  include Mongoid::Timestamps
  include Graphoid::Queries
  include Graphoid::Mutations

  field :text, type: String
  field :name, type: String

  embedded_in :account
end
