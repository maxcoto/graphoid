# frozen_string_literal: true

require 'rails_helper'

describe 'QueryHasOne', type: :request do
  let!(:delete) { Account.delete_all; Person.delete_all }
  subject { Helper.resolve(self, 'accounts', @query) }

  let!(:a0) { Account.create!(string_field: 'bob') }
  let!(:a1) { Account.create!(string_field: 'bob') }
  let!(:a2) { Account.create!(string_field: 'boc') }

  let!(:p0) { Person.create!(snake_case: 'a', account: a0) }
  let!(:p1) { Person.create!(snake_case: 'b', account: a1) }
  let!(:p2) { Person.create!(snake_case: 'c', account: a2) }

  describe 'filtering with conditions in has_one relations' do
    it 'filters by has_one relation' do
      @query = %{
        query {
          accounts(where: {
            stringField: "bob",
            person: { snakeCase: "b" }
          }) {
            id
            person {
              id
            }
          }
        }
      }

      expect(subject.size).to eq(1)
      expect(subject[0]['id']).to eq a1.id.to_s
      expect(subject[0]['person']['id']).to eq p1.id.to_s
    end
  end
end
