# TODO: elaborate more complex cases
require 'rails_helper'

describe "QueryGraphields", :type => :request do

  let!(:delete) { Account.delete_all }
  subject { Helper.resolve(self, "accounts", @query) }
  let!(:a0) { Account.create!(integer_field: 2, string_field: "maxi")}

  it "loads graphields by calling the method" do
    @query = %{
      query {
        accounts {
          id
          graphield0
          graphField1
          graphField2
        }
      }
    }

    expect(subject[0]["graphield0"]).to eq "maxi custom 0"
    expect(subject[0]["graphField1"]).to eq "maxi custom 1"
    expect(subject[0]["graphField2"].to_s).to eq "12"
  end
  
  it "fails when calling a forbidden (graphorbid) field" do
    query = %{
      query {
        accounts {
          id
          forbidden
        }
      }
    }

    post "/graphql", params: { query: query }
    body = @response.body
    pp body if ENV['DEBUG']
    result = JSON.parse(body)["errors"][0]["message"]

    expect(result).to eq "Field 'forbidden' doesn't exist on type 'AccountType'"
  end
end
