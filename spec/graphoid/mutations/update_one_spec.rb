# frozen_string_literal: true

require 'rails_helper'

describe 'MutationUpdateOne', type: :request do
  before { Account.delete_all }
  subject { Helper.resolve(self, 'updateAccount', @query) }

  let!(:account) { Account.create!(integer_field: 4, float_field: 4.2, string_field: 'bob', snake_case: 'snake', camelCase: 'camel', datetime_field: DateTime.iso8601) }

  it 'updates one object by id' do
    @query = %{
      mutation {
        updateAccount(id: "#{account.id}", data: {
          integerField: 3,
          floatField: 3.2,
          stringField: null,
          snakeCase: "camel",
          camelCase: "snake",
          datetimeField: "2018-10-01T23:59:59"
        }){
          id
        }
      }
    }

    persisted = Account.find(subject['id'])

    expect(persisted.integer_field).to eq(3)
    expect(persisted.float_field).to eq(3.2)
    expect(persisted.string_field).to eq(nil)
    expect(persisted.snakeCase).to eq('camel')
    expect(persisted.camelCase).to eq('snake')
    expect(persisted.datetime_field).to eq('2018-10-01T23:59:59.000+00:00')
  end

  it 'updates and sets updated_by if exists' do
    @action = 'updateAccount'

    @query = %{
      mutation {
        updateAccount(id: "#{account.id}", data: {
          integerField: 5
        }) {
          id
        }
      }
    }

    persisted = Account.find(subject['id'])
    expect(persisted.updated_by.name).to eq('maxi')
  end
end
