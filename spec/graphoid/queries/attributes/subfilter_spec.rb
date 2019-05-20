# frozen_string_literal: true

# TODO: should apply submodel filtering on embeeded relations
# TODO: elaborate more complex cases

require 'rails_helper'

describe 'QuerySubFilter', type: :request do
  subject { Helper.resolve(self, @action, @query) }

  before(:all) do
    Person.delete_all
    Label.delete_all
    Account.delete_all
    House.delete_all

    @h0 = House.create!(name: 'h0')
    @a0 = Account.create!(integer_field: 2, house: @h0)
    @p0 = Person.create!(account: @a0, name: 'p0', snake_case: 'snake', camelCase: 'camel')
    @l0 = Label.create!(account: @a0, name: 'l0', amount: 2)
    @l1 = Label.create!(account: @a0, name: 'l1', amount: 2)
  end

  after(:all) do
    [@h0, @a0, @p0, @l0, @l1].map(&:destroy)
  end

  describe 'applies filters in related models' do
    it 'when has many' do
      @action = 'accounts'
      @query = %{
        query {
          accounts {
            id
            labels(where: { amount: 2, name: "l0" }) {
              id
            }
          }
        }
      }

      expect(subject[0]['labels'].size).to eq(1)
      expect(subject[0]['labels'][0]['id']).to eq @l0.id.to_s
    end

    it 'when has one and does not match' do
      @action = 'account'
      @query = %{
        query {
          account {
            id
            person(where: { name: "something" }) {
              id
            }
          }
        }
      }

      expect(subject['person']).not_to be
    end

    it 'when has one and matches' do
      @action = 'account'
      @query = %{
        query {
          account {
            id
            person(where: { name: "p0" }) {
              id
            }
          }
        }
      }

      expect(subject['person']['id']).to eq @p0.id.to_s
    end

    it 'when belongs to and does not match' do
      @action = 'account'
      @query = %{
        query {
          account {
            id
            house(where: { name: "something" }) {
              id
            }
          }
        }
      }

      expect(subject['house']).not_to be
    end

    it 'when belongs to and does and matches' do
      @action = 'account'
      @query = %{
        query {
          account {
            id
            house(where: { name: "h0" }) {
              id
            }
          }
        }
      }

      expect(subject['house']['id']).to eq @h0.id.to_s
    end
  end
end
