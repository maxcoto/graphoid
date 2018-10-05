require 'rails_helper'

describe "QueryHasOneThrough", :type => :request do
  next #if ENV['DRIVER'] == "mongo"
  # TODO: make "through" relations not always be referenced to many.

  let!(:delete) { Brain.delete_all; Person.delete_all; Account.delete_all }
  subject { Helper.resolve(self, "accounts", @query) }

  let!(:a0) { Account.create! }
  let!(:a1) { Account.create! }
  let!(:a2) { Account.create! }

  let!(:p0) { Person.create!(account: a0) }
  let!(:p1) { Person.create!(account: a1) }
  let!(:p2) { Person.create!(account: a2) }

  let!(:b0) { Brain.create!(name: 'b0', person: p0) }
  let!(:b1) { Brain.create!(name: 'b1', person: p1) }
  let!(:b2) { Brain.create!(name: 'c0', person: p2) }

  describe "filtering with conditions in has_one_through relations" do

    it "filters by has_one relation" do
      @query = %{
        query {
          accounts(where: {
            brain: { name_contains: "b" }
          }) {
            id
            brain {
              id
            }
          }
        }
      }

      expect(subject.size).to eq(2)

      expect(subject[0]["id"]).to eq a0.id.to_s
      expect(subject[0]["brain"]["id"]).to eq b0.id.to_s

      expect(subject[1]["id"]).to eq a1.id.to_s
      expect(subject[1]["brain"]["id"]).to eq b1.id.to_s
    end
  end
end
