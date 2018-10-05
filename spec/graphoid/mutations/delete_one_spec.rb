# frozen_string_literal: true

require 'rails_helper'

describe 'MutationDeleteOne', type: :request do
  before { Account.delete_all }
  subject { Helper.resolve(self, 'deleteAccount', @query) }

  let!(:account) { Account.create!(string_field: 'bob') }

  it 'deletes one object by id' do
    @query = %{
      mutation {
        deleteAccount(id: "#{account.id}"){
          id
        }
      }
    }

    expect(subject['id']).to eq(account.id.to_s)
    error = ENV['DRIVER'] == 'mongo' ? Mongoid::Errors::DocumentNotFound : ActiveRecord::RecordNotFound
    expect { account.reload }.to raise_error(error)
  end
end
