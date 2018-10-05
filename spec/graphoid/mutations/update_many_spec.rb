require 'rails_helper'

describe "MutationUpdateMany", :type => :request do

  before { Account.delete_all }
  subject { Helper.resolve(self, "updateManyAccounts", @query) }

  let!(:a0) { Account.create!(string_field: "account0", snake_case: "snake", camelCase: "camel") }
  let!(:a1) { Account.create!(string_field: "account1", snake_case: "snake", camelCase: "camel") }
  let!(:a2) { Account.create!(string_field: "account2", snake_case: "snaki", camelCase: "camel") }

  it "updates many objects by condition" do
    @query = %{
      mutation M {
        updateManyAccounts(where: { snakeCase: "snake" }, data: { camelCase: "updated" }){
          id
          camelCase
        }
      }
    }

    expect(subject[0]["camelCase"]).to eq("updated")
    expect(subject[1]["camelCase"]).to eq("updated")
    expect(a2.reload.camelCase).to eq("camel")
  end
end
