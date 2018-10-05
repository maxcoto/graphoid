# frozen_string_literal: true

require 'rails_helper'

describe 'MutationCreateOne', type: :request do
  before { Account.delete_all }
  subject { Helper.resolve(self, 'createAccount', @query) }

  it 'creates one object' do
    @action = 'createAccount'

    @query = %{
      mutation {
        createAccount(data: {
          integerField: 3,
          floatField: 3.2,
          stringField: "bob",
          snakeCase: "snake",
          camelCase: "camel",
          datetimeField: "2018-10-01T23:59:59"
        }) {
          id
        }
      }
    }

    persisted = Account.find(subject['id'])

    expect(persisted.integer_field).to eq(3)
    expect(persisted.float_field).to eq(3.2)
    expect(persisted.string_field).to eq('bob')
    expect(persisted.snakeCase).to eq('snake')
    expect(persisted.camelCase).to eq('camel')
    expect(persisted.datetime_field).to eq('2018-10-01T23:59:59.000+00:00')
  end

  it 'creates and sets created_by and updated_by if exists' do
    @action = 'createAccount'

    @query = %{
      mutation {
        createAccount(data: {
          integerField: 3
        }) {
          id
        }
      }
    }

    persisted = Account.find(subject['id'])
    expect(persisted.created_by.name).to eq('maxi')
    expect(persisted.updated_by.name).to eq('maxi')
  end
end
