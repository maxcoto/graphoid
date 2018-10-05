# frozen_string_literal: true

require 'rails_helper'

describe 'QueryBelongsTo', type: :request do
  let!(:delete) { Account.delete_all; Person.delete_all; }
  subject { Helper.resolve(self, 'people', @query) }

  let!(:a0) { Account.create!(string_field: 'bobi') }
  let!(:a1) { Account.create!(string_field: 'boca') }
  let!(:a2) { Account.create!(string_field: 'boce') }

  let!(:p0) { Person.create!(camelCase: 'a', account: a0) }
  let!(:p1) { Person.create!(camelCase: 'b', account: a1) }
  let!(:p2) { Person.create!(camelCase: 'c', account: a2) }

  describe 'belongs_to' do
    it 'filters belongs_to relation' do
      @query = %{
        query {
          people(where: {
            account: { stringField_contains: "boc" }
          }) {
            id
            account {
              id
            }
          }
        }
      }

      expect(subject.size).to eq(2)
      expect(subject[0]['id']).to eq p1.id.to_s
      expect(subject[1]['id']).to eq p2.id.to_s
      expect(subject[0]['account']['id']).to eq a1.id.to_s
      expect(subject[1]['account']['id']).to eq a2.id.to_s
    end
  end
end
