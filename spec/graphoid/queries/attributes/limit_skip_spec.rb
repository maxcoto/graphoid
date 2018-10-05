# frozen_string_literal: true

require 'rails_helper'

describe 'QueryLimitSkip', type: :request do
  let!(:delete) { Account.delete_all }
  subject { Helper.resolve(self, 'accounts', @query).map { |account| account['id'] } }

  let!(:a0) { Account.create!(integer_field: 2) }
  let!(:a1) { Account.create!(integer_field: 1) }
  let!(:a2) { Account.create!(integer_field: 2) }
  let!(:a3) { Account.create!(integer_field: 2) }

  it 'limits many objects' do
    @query = %{
      query {
        accounts(limit: 2) {
          id
        }
      }
    }

    expect(subject.size).to eq(2)
  end

  it 'skips many objects' do
    @query = %{
      query {
        accounts(skip: 1) {
          id
        }
      }
    }

    expect(subject).to eq Helper.ids_of(a1, a2, a3)
  end
end
