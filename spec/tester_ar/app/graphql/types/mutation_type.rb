# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    field :test_field, String, null: false
  end
end
