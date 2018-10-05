# frozen_string_literal: true

require 'rails_helper'

describe 'QueryFieldTypes', type: :request do
  before { Account.delete_all }
  subject { Helper.resolve(self, 'account', @query) }

  let!(:now) { DateTime.iso8601 }
  let!(:a0) { Account.create!(integer_field: 4, float_field: 4.2, string_field: 'bob', snake_case: 'snake', camelCase: 'camel', datetime_field: now) }
  let!(:a1) { Account.create!(string_field: 'bobi2') }

  it 'loads one object by id' do
    @query = %{
      query {
        account(id: "#{a0.id}" ){
          id
          integerField
          floatField
          stringField
          snakeCase
          camelCase
          datetimeField
        }
      }
    }

    expect(subject['id']).to            eq(a0.id.to_s)
    expect(subject['integerField']).to  eq(a0.integer_field)
    expect(subject['floatField']).to    eq(a0.float_field)
    expect(subject['stringField']).to   eq(a0.string_field)
    expect(subject['snakeCase']).to     eq(a0.snake_case)
    expect(subject['camelCase']).to     eq(a0.camelCase)

    # TODO
    # expect(subject["datetimeField"]).to eq(now)
  end

  it 'loads one object by condition' do
    @query = %{
      query {
        account(where: { stringField_contains: "bobi" } ){
          id
        }
      }
    }

    expect(subject['id']).to eq(a1.id.to_s)
  end
end
