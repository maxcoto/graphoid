require 'rails_helper'

describe "MutationCreateMany", :type => :request do

  before { Account.delete_all }
  subject { Helper.resolve(self, "createAccounts", @query) }

  it "creates many objects" do
    @query = %{
      mutation {
        createAccounts(data: [
          { camelCase: "camel0", snakeCase: "snake0", stringField: "account0" },
          { camelCase: "camel1", snakeCase: "snake1", stringField: "account1" },
        ]){
          id
        }
      }
    }

    expect(Account.find(subject[0]["id"])).to be
    expect(Account.find(subject[1]["id"])).to be
  end

end
