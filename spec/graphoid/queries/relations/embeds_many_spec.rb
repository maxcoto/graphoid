require 'rails_helper'

describe "QueryEmbedsMany", :type => :request do
  next

  let!(:delete) { Account.delete_all; Label.delete_all }
  subject { Helper.resolve(self, "accounts", @query) }

  let!(:a0) { Account.create!(string_field: 'bob') }
  let!(:a1) { Account.create!(string_field: 'bob') }
  let!(:a2) { Account.create!(string_field: 'boc') }

  let!(:s0) { Snake.create!(name: 'a', camelCase: 1, account: a0) }
  let!(:s1) { Snake.create!(name: 'a', camelCase: 2, account: a0) }
  let!(:s2) { Snake.create!(name: 'a', camelCase: 1, account: a1) }
  let!(:s3) { Snake.create!(name: 'a', camelCase: 2, account: a1) }
  let!(:s4) { Snake.create!(name: 'a', camelCase: 1, account: a2) }
  let!(:s5) { Snake.create!(name: 'a', camelCase: 2, account: a2) }

  describe "filtering with conditions in embeds_many relations" do
    it "filters _some" do
     @query = %{
       query {
         accounts(where: {
           stringField: "bob",
           snakes_some: { snakeCase: "a", camelCase: "c" }
         }) {
           id
           labels {
             id
           }
         }
       }
     }

     # TODO: Not Implemented
     pending
     fail

     if ENV['DRIVER'] == "mongo"
       expect(subject.size).to eq(1)
       expect(subject[0]["id"]).to eq a0.id.to_s
       expect(subject[0]["labels"][0]["id"]).to eq s0.id.to_s
       expect(subject[0]["labels"][1]["id"]).to eq s1.id.to_s
     end
    end

    it "filters _none" do
     @query = %{
       query {
         accounts(where: {
           snakes_none: { snakeCase: "a", camelCase: "c" }
         }) {
           id
           labels {
             id
           }
         }
       }
     }

     if ENV['DRIVER'] == "mongo"
       # TODO: Not Implemented
       pending
       fail

       expect(subject.size).to eq(2)
       expect(subject[0]["id"]).to eq a1.id.to_s
       expect(subject[1]["id"]).to eq a2.id.to_s

       expect(subject[0]["labels"][0]["id"]).to eq s2.id.to_s
       expect(subject[0]["labels"][1]["id"]).to eq s3.id.to_s

       expect(subject[1]["labels"][0]["id"]).to eq s4.id.to_s
       expect(subject[1]["labels"][1]["id"]).to eq s5.id.to_s
     end
    end

    it "filters _every" do
     @query = %{
       query {
         accounts(where: {
           snakes_every: { snakeCase: "a", camelCase: "b" }
         }) {
           id
           labels {
             id
           }
         }
       }
     }

     if ENV['DRIVER'] == "mongo"
       # TODO: Not Implemented
       pending
       fail

       expect(subject.size).to eq(1)
       expect(subject[0]["id"]).to eq a2.id.to_s
       expect(subject[0]["snakes"][0]["id"]).to eq s4.id.to_s
       expect(subject[0]["snakes"][1]["id"]).to eq s5.id.to_s
     end
    end
  end
end
