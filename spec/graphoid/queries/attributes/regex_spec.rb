# frozen_string_literal: true

require 'rails_helper'

describe 'QueryRegex', type: :request do
  next if ENV['DRIVER'] != 'mongo'

  let!(:delete) { Account.delete_all }
  subject { Helper.resolve(self, 'accounts', @query).map { |account| account['id'] } }

  let!(:a0) { Account.create!(snake_case: 'snaki', camelCase: 'camol') }
  let!(:a1) { Account.create!(snake_case: 'snaki', camelCase: 'camol') }
  let!(:a2) { Account.create!(snake_case: 'snaki', camelCase: 'camol') }
  let!(:a3) { Account.create!(snake_case: nil,     camelCase: 'camol') }
  let!(:a4) { Account.create!(snake_case: '',      camelCase: 'camel') }
  let!(:a5) { Account.create!(snake_case: 'snake', camelCase: 'zzzzz') }
  let!(:a6) { Account.create!(snake_case: 'snake', camelCase: '12345') }

  describe 'filtering using _regex' do
    it 'with a string camelCased field' do
      @query = %{
        query {
          accounts(where: {
            camelCase_regex: "[a-z]"
          }) {
            id
          }
        }
      }

      expect(subject).to match_array Helper.ids_of(a0, a1, a2, a3, a4, a5)
    end

    it 'with a string snake_case field' do
      @query = %{
        query {
          accounts(where: {
            snakeCase_regex: "...ki"
          }) {
            id
          }
        }
      }

      expect(subject).to match_array Helper.ids_of(a0, a1, a2)
    end

    it 'with an empty string value' do
      @query = %{
        query {
          accounts(where: {
            snakeCase_regex: ""
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
            snakeCase_regex: null
          }) {
            id
          }
        }
      }

      expect(subject).to match_array Helper.ids_of(a0, a1, a2, a4, a5, a6)
    end
  end
end
