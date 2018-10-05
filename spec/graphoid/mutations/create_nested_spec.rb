# frozen_string_literal: true

require 'rails_helper'

describe 'MutationCreateNested', type: :request do
  before { Account.delete_all }
  subject { Helper.resolve(self, 'createAccount', @query) }

  it 'creates one object with referenced relations' do
    @query = %{
      mutation {
        createAccount(data: {
          stringField: "bob",
          person: { name: "Bryan" },
          labels: [{ name: "Kevin" }, { amount: 18.0 }],
          house: { name: "Alesi" }
        }) {
          id
          person {
            id
          }
          labels {
            id
          }
        }
      }
    }

    persisted = Account.find(subject['id'])
    persisted.reload

    expect(persisted.person.name).to eq('Bryan')
    expect(persisted.labels[0].name).to eq('Kevin')
    expect(persisted.labels[1].amount).to eq(18.0)
    expect(persisted.house.name).to eq('Alesi')
  end

  it 'creates objects in a many to many referenced relation' do
    @query = %{
      mutation {
        createAccount(data: {
          users: [ { name: "maxi" } ]
        }) {
          id
          users {
            id
          }
        }
      }
    }

    persisted = Account.find(subject['id'])
    persisted.reload
    expect(persisted.users[0].name).to eq('maxi')
  end

  it 'creates objects in a many to many through referenced relation' do
    @query = %{
      mutation {
        createPlayer(data: {
          teams: [ { name: "maxi" } ]
        }) {
          id
          teams {
            id
          }
        }
      }
    }

    if ENV['DRIVER'] != 'mongo'
      execution = Helper.resolve(self, 'createPlayer', @query)
      persisted = Player.find(execution['id'])
      persisted.reload
      expect(persisted.teams[0].name).to eq('maxi')
    end
  end

  it 'creates one object with embedded relations' do
    @query = %{
      mutation {
        createAccount(data: {
          stringField: "bob",
          value: { text: "Bryan" },
          snakes: [{ name: "Kevin", snakeCase: 13.5 }, { camelCase: 18 }]
        }) {
          id
          value {
            id
          }
          snakes {
            id
          }
        }
      }
    }

    if ENV['DRIVER'] == 'mongo'
      persisted = Account.find(subject['id'])
      persisted.reload

      expect(persisted.value.text).to eq('Bryan')

      expect(persisted.snakes[0].name).to eq('Kevin')
      expect(persisted.snakes[0].snake_case).to eq(13.5)
      expect(persisted.snakes[1].camelCase).to eq(18.0)
    end
  end
end
