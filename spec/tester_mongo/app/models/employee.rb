# frozen_string_literal: true

class Employee
  include Mongoid::Document
  include Mongoid::Timestamps

  include Graphoid::Queries
  include Graphoid::Mutations

  field :manager_id, type: BSON::ObjectId

  has_many :subordinates, class_name: 'Employee', foreign_key: 'manager_id'
  belongs_to :manager, class_name: 'Employee'
end
