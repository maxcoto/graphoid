require 'rails_helper'

describe "MutationDeleteMany", :type => :request do

  before { Account.delete_all }
  subject { Helper.resolve(self, @action, @query) }

  let!(:a0) { Account.create!(string_field: "bob") }
  let!(:a1) { Account.create!(string_field: "bob") }
  let!(:a2) { Account.create!(string_field: "oob") }

  it "deletes many objects by condition" do
    @action = "deleteManyAccounts"

    @query = %{
      mutation {
        deleteManyAccounts(where: { stringField: "bob" }){
          id
        }
      }
    }

    expect(Account.count).to eq(3)
    subject
    expect(Account.count).to eq(1)
    expect(Account.first.string_field).to eq("oob")
  end
end
