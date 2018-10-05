require 'rails_helper'

describe "QueryIn", :type => :request do

  let!(:delete) { Account.delete_all }
  subject { Helper.resolve(self, "accounts", @query).map { |account| account["id"] } }

  let!(:a0) { Account.create!(integer_field: 2, float_field: 4.3, string_field: 'boc', snake_case: 'snaki', camelCase: 'camol' )}
  let!(:a1) { Account.create!(integer_field: 1, float_field: 4.3, string_field: 'boc', snake_case: 'snaki', camelCase: 'camol' )}
  let!(:a2) { Account.create!(integer_field: 2, float_field: 4.2, string_field: 'boc', snake_case: 'snaki', camelCase: 'camol' )}
  let!(:a3) { Account.create!(integer_field: 2, float_field: 4.3, string_field: 'bob', snake_case: nil,     camelCase: 'camol' )}
  let!(:a4) { Account.create!(integer_field: 2, float_field: 4.3, string_field: 'boc', snake_case: '',      camelCase: 'camel' )}
  let!(:a5) { Account.create!(integer_field: 1, float_field: 4.2, string_field: nil,   snake_case: 'snake', camelCase: 'camel' )}
  let!(:a6) { Account.create!(integer_field: 0, float_field: 4.5, string_field: '',    snake_case: 'snake', camelCase: 'camel' )}

  describe "filtering using _in" do
    it "with a string camelCased field" do
      @query = %{
        query {
          accounts(where: {
            camelCase_in: ["camol"]
          }) {
            id
          }
        }
      }

      expect(subject).to eq Helper.ids_of(a0, a1, a2, a3)
    end

    it "with null" do
      @query = %{
        query {
          accounts(where: {
            snakeCase_in: [null]
          }) {
            id
          }
        }
      }

      # TODO
      pending("TEST IS CORRECT - FIX IMPLEMENTATION FOR AR")
      fail

      expect(subject).to eq Helper.ids_of(a3)
    end

    it "with an empty array" do
      @query = %{
        query {
          accounts(where: {
            stringField_in: []
          }) {
            id
          }
        }
      }

      expect(subject).to eq []
    end

    it "with numeric values" do
      @query = %{
        query {
          accounts(where: {
            OR: [
              { floatField_in: [4.2] },
              { integerField_in: [1, 0] }
            ]
          }) {
            id
          }
        }
      }

      expect(subject.size).to eq(4)
      expect(subject).to eq Helper.ids_of(a1, a2, a5, a6)
    end

    it "with an empty string" do
      @query = %{
        query {
          accounts(where: {
            stringField_in: [""]
          }) {
            id
          }
        }
      }

      expect(subject).to eq Helper.ids_of(a6)
    end
  end

end
