class Value
  include Mongoid::Document
  include Mongoid::Timestamps
  include Graphoid::Queries
  include Graphoid::Mutations

  field :text, type: String

  embedded_in :account
end
