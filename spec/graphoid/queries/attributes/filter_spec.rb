# TODO: elaborate more complex cases
require 'rails_helper'

describe "QueryFilter", :type => :request do

  let!(:delete) { Account.delete_all }
  subject { Helper.resolve(self, "accounts", @query).map { |a| a["id"] } }

  let!(:yesterday) { DateTime.yesterday.to_time.iso8601 }
  let!(:today)     { DateTime.now.iso8601 }
  let!(:tomorrow)  { DateTime.tomorrow.to_time.iso8601 }

  let!(:a0) { Account.create!(integer_field: 2, float_field: 4.3, string_field: 'boc', snake_case: 'snaki', camelCase: 'camol', datetime_field: yesterday )}
  let!(:a1) { Account.create!(integer_field: 1, float_field: 4.3, string_field: 'boc', snake_case: 'snaki', camelCase: 'camol', datetime_field: yesterday )}
  let!(:a2) { Account.create!(integer_field: 2, float_field: 4.2, string_field: 'boc', snake_case: 'snaki', camelCase: 'camol', datetime_field: yesterday )}
  let!(:a3) { Account.create!(integer_field: 2, float_field: 4.3, string_field: 'bob', snake_case: 'snaki', camelCase: 'camol', datetime_field: today     )}
  let!(:a4) { Account.create!(integer_field: 2, float_field: 4.3, string_field: 'boc', snake_case: 'snake', camelCase: 'camel', datetime_field: today     )}
  let!(:a5) { Account.create!(integer_field: 1, float_field: 4.2, string_field: 'bob', snake_case: 'snake', camelCase: 'camel', datetime_field: tomorrow  )}
  let!(:a6) { Account.create!(integer_field: 1, float_field: 4.2, string_field: 'bob', snake_case: 'snake', camelCase: 'camel', datetime_field: tomorrow  )}

  it "loads many objects" do
    @query = %{
      query {
        accounts {
          id
        }
      }
    }

    expect(subject.size).to eq(7)
  end

  describe "filtering with nested conditions" do

    it "applies an OR and AND on regular fields" do
      @query = %{
        query {
          accounts(where: {
            OR: [
              { integerField: 1 },
              { floatField: 4.2 },
              { stringField: "bob" },
              { snakeCase: "snake", camelCase: "camel" }
            ],
            AND: [
              { datetimeField: "#{yesterday}" }
            ]
          }) {
            id
          }
        }
      }

      expect(subject.size).to eq(2)
      expect(subject).to eq Helper.ids_of(a1, a2)
    end

    it "applies special conditions fields" do
      @query = %{
        query {
          accounts(where: {
            integerField_gte: 2,
            floatField_lt: 4.4,
            stringField_contains: "boc",
            snakeCase_not: "snake"
          }) {
            id
          }
        }
      }

      expect(subject.size).to eq(2)
      expect(subject).to eq Helper.ids_of(a0, a2)
    end

    it "applies _in and _nin conditions fields" do
      @query = %{
        query {
          accounts(where: {
            integerField_in: [2, 3],
            floatField_nin: [4.2],
            snakeCase_in: ["snaki"]
          }) {
            id
          }
        }
      }

      expect(subject.size).to eq(2)
      expect(subject).to eq Helper.ids_of(a0, a3)
    end
  end
end
