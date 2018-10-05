# frozen_string_literal: true

require 'rails_helper'

describe 'QueryEmbedsOne', type: :request do
  next if ENV['DRIVER'] != 'mongo'

  let!(:delete) { Account.delete_all; Person.delete_all }
  subject { Helper.resolve(self, 'accounts', @query) }

  let!(:a0) { Account.create!(string_field: 'bob') }
  let!(:a1) { Account.create!(string_field: 'bob') }
  let!(:a2) { Account.create!(string_field: 'boc') }

  let!(:v0) { Value.create!(text: 'ac', name: 'ac', account: a0) }
  let!(:v1) { Value.create!(text: 'ba', name: 'aa', account: a1) }
  let!(:v2) { Value.create!(text: 'bb', name: 'ab', account: a2) }

  describe 'filtering with conditions in embeds_one relations' do
    it 'filters properly' do
      @query = %{
        query {
          accounts(where: {
            value: { text: "bb" }
          }) {
            id
            value {
              id
            }
          }
        }
      }

      expect(subject.size).to eq(1)
      expect(subject[0]['id']).to eq a2.id.to_s
      expect(subject[0]['value']['id']).to eq v2.id.to_s
    end

    it 'with _filter' do
      @query = %{
        query {
          accounts(where: {
            stringField: "bob",
            value: { text_contains: "a", name_not: "ac" }
          }) {
            id
            value {
              id
            }
          }
        }
      }

      expect(subject.size).to eq(1)
      expect(subject[0]['id']).to eq a1.id.to_s
      expect(subject[0]['value']['id']).to eq v1.id.to_s
    end

    it 'with OR' do
      @query = %{
        query {
          accounts(where: {
            value: { OR: [ { text: "b" }, { text: "c" } ] }
          }) {
            id
            value {
              id
            }
          }
        }
      }

      pending('this implementation needs more brain cells')
      raise

      expect(subject.size).to eq(3)
      expect(subject[0]['id']).to eq a1.id.to_s
      expect(subject[0]['value']['id']).to eq v1.id.to_s
    end
  end
end
