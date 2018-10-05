class Person < ApplicationRecord
  #belongs_to :ref_many_account, class_name: "Account", inverse_of: :refs_many, optional: true
  include Graphoid::Queries
  include Graphoid::Mutations

  belongs_to :account
  has_one :brain
end
