# frozen_string_literal: true

require 'rails_helper'

describe 'QueryContains', type: :request do
  let!(:delete) { Account.delete_all }
  subject { Helper.resolve(self, 'accounts', @query).map { |account| account['id'] } }

  let!(:a0) { Account.create!(snake_case: 'snaki', camelCase: 'camol') }
  let!(:a1) { Account.create!(snake_case: 'snaki', camelCase: 'camol') }
  let!(:a2) { Account.create!(snake_case: 'snaki', camelCase: 'camol') }
  let!(:a3) { Account.create!(snake_case: nil,     camelCase: 'camol') }
  let!(:a4) { Account.create!(snake_case: '',      camelCase: 'camel') }
  let!(:a5) { Account.create!(snake_case: 'snake', camelCase: 'camel') }
  let!(:a6) { Account.create!(snake_case: 'snake', camelCase: 'camel') }

  describe 'filtering using _contains' do
    it 'with a string camelCased field' do
      @query = %{
        query {
          accounts(where: {
            camelCase_contains: "ol"
          }) {
            id
          }
        }
      }

      expect(subject).to eq Helper.ids_of(a0, a1, a2, a3)
    end

    it 'with a string snake_case field' do
      @query = %{
        query {
          accounts(where: {
            snakeCase_contains: "ki"
          }) {
            id
          }
        }
      }

      expect(subject).to eq Helper.ids_of(a0, a1, a2)
    end

    it 'with an empty string value' do
      @query = %{
        query {
          accounts(where: {
            snakeCase_contains: ""
          }) {
            id
          }
        }
      }

      expect(subject).to match_array Helper.ids_of(a0, a1, a2, a4, a5, a6)
    end

    it 'with a null value' do
      @query = %{
        query {
          accounts(where: {
            snakeCase_contains: null
          }) {
            id
          }
        }
      }

      expect(subject).to match_array Helper.ids_of(a0, a1, a2, a4, a5, a6)
    end
  end
end
