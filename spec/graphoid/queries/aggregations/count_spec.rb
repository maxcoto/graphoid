require 'rails_helper'

describe "QueryAndCount", :type => :request do
  let!(:delete) { Account.delete_all }
  subject { Helper.resolve(self, "_accountsMeta", @query)["count"] }

  let!(:a0) { Account.create!(snake_case: 'snaki', camelCase: 'camol' )}
  let!(:a1) { Account.create!(snake_case: 'snaki', camelCase: 'camol' )}
  let!(:a2) { Account.create!(snake_case: 'snaki', camelCase: 'camol' )}
  let!(:a3) { Account.create!(snake_case: 'snake', camelCase: 'camel' )}
  let!(:a4) { Account.create!(snake_case: 'snake', camelCase: 'camel' )}

  describe "count on models" do
    it "with a string camelCased field" do
      @query = %{
        query {
          _accountsMeta {
            count
          }
        }
      }

      expect(subject).to eq 5
    end

    it "with a filter" do
      @query = %{
        query {
          _accountsMeta(where: {
            snakeCase_contains: "ki"
          }) {
            count
          }
        }
      }

      expect(subject).to eq 3
    end
  end
end
