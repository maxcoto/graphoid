# frozen_string_literal: true

class Employee < ApplicationRecord
  has_many :subordinates, class_name: 'Employee', foreign_key: 'manager_id'
  belongs_to :manager, class_name: 'Employee'
  
  include Graphoid::Queries
  include Graphoid::Mutations
end
