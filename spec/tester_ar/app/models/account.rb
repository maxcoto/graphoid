class Account < ApplicationRecord
  include Graphoid::Queries
  include Graphoid::Mutations
  include Graphoid::Graphield

  graphield :graphield0, String
  graphield :graph_field_1, String
  graphield :graphField2, Integer

  graphorbid :forbidden

  def graphield0
    string_field.to_s + ' custom 0'
  end

  def graph_field_1
    string_field.to_s + ' custom 1'
  end

  def graphField2
    integer_field.to_i + 10
  end

  has_one :person, dependent: :destroy
  has_one :brain, through: :person

  has_many :labels, dependent: :destroy
  belongs_to :house, optional: true

  belongs_to :created_by, class_name: "User", optional: true
  belongs_to :updated_by, class_name: "User", optional: true

  has_and_belongs_to_many :users
end
