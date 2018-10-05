# frozen_string_literal: true

require 'rails_helper'

describe 'QueryNot', type: :request do
  let!(:delete) { Account.delete_all }
  subject { Helper.resolve(self, 'accounts', @query).map { |account| account['id'] } }

  let!(:a0) { Account.create!(integer_field: 2, float_field: 4.3, string_field: 'boc', snake_case: 'snaki', camelCase: 'camol') }
  let!(:a1) { Account.create!(integer_field: 1, float_field: 4.3, string_field: 'boc', snake_case: 'snaki', camelCase: 'camol') }
  let!(:a2) { Account.create!(integer_field: 2, float_field: 4.2, string_field: 'boc', snake_case: 'snaki', camelCase: 'camol') }
  let!(:a3) { Account.create!(integer_field: 2, float_field: 4.3, string_field: 'bob', snake_case: 'snaki', camelCase: 'camol') }
  let!(:a4) { Account.create!(integer_field: 2, float_field: 4.3, string_field: 'boc', snake_case: 'snake', camelCase: 'camel') }
  let!(:a5) { Account.create!(integer_field: 1, float_field: 4.2, string_field: nil,   snake_case: nil,     camelCase: 'camel') }
  let!(:a6) { Account.create!(integer_field: 0, float_field: 4.5, string_field: '',    snake_case: '',      camelCase: 'camel') }

  describe 'filtering using not' do
    it 'with a string camelCased field' do
      @query = %{
        query {
          accounts(where: {
            camelCase_not: "camol"
          }) {
            id
          }
        }
      }

      expect(subject).to eq Helper.ids_of(a4, a5, a6)
    end

    it 'with a null string value' do
      @query = %{
        query {
          accounts(where: {
            snakeCase_not: null
          }) {
            id
          }
        }
      }

      expect(subject).to eq Helper.ids_of(a0, a1, a2, a3, a4, a6)
    end

    it 'with an empty string' do
      @query = %{
        query {
          accounts(where: {
            stringField_not: ""
          }) {
            id
          }
        }
      }

      # TODO: ? it does not load nil values in active record
      # but it does load them in mongo. feature? bug?

      if ENV['DRIVER'] == 'mongo'
        expect(subject).to eq Helper.ids_of(a0, a1, a2, a3, a4, a5)
      else
        expect(subject).to eq Helper.ids_of(a0, a1, a2, a3, a4)
      end
    end

    it 'with numeric values' do
      @query = %{
        query {
          accounts(where: {
            AND: [
              { floatField_not: 4.2 },
              { integerField_not: 2 }
            ]
          }) {
            id
          }
        }
      }

      expect(subject).to eq Helper.ids_of(a1, a6)
    end

    it 'with a false boolean value' do
      @query = %{
        query {
          accounts(where: {
            booleanField_not: false
          }) {
            id
          }
        }
      }

      # TODO: IMPLEMENT A BOOLEAN FIELD
      pending('IMPLEMENT A BOOLEAN FIELD')
      raise

      expect(subject).to eq Helper.ids_of(a4, a5, a6)
    end

    it 'with a true boolean value' do
      @query = %{
        query {
          accounts(where: {
            booleanField_not: true
          }) {
            id
          }
        }
      }

      # TODO: IMPLEMENT A BOOLEAN FIELD
      pending('IMPLEMENT A BOOLEAN FIELD')
      raise

      # expect(subject).to eq Helper.ids_of(a4, a5, a6)
    end

    it 'with a null boolean value' do
      @query = %{
        query {
          accounts(where: {
            booleanField_not: null
          }) {
            id
          }
        }
      }

      # TODO: IMPLEMENT A BOOLEAN FIELD
      pending('IMPLEMENT A BOOLEAN FIELD')
      raise

      # expect(subject).to eq Helper.ids_of(a4, a5, a6)
    end
  end
end
