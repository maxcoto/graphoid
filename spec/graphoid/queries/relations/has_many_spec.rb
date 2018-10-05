require 'rails_helper'

describe "QueryHasMany", :type => :request do

  let!(:delete) { Account.delete_all; Label.delete_all }
  subject { Helper.resolve(self, "accounts", @query) }

  let!(:a0) { Account.create!(string_field: 'bob') }
  let!(:a1) { Account.create!(string_field: 'boc') }
  let!(:a2) { Account.create!(string_field: 'bob') }

  let!(:l0) { Label.create!(name: 'a', amount: 1, account: a0) }
  let!(:l1) { Label.create!(name: 'a', amount: 2, account: a0) }
  let!(:l2) { Label.create!(name: 'a', amount: 1, account: a1) }
  let!(:l3) { Label.create!(name: 'a', amount: 2, account: a1) }
  let!(:l4) { Label.create!(name: 'a', amount: 1, account: a2) }
  let!(:l5) { Label.create!(name: 'b', amount: 3, account: a2) }

  describe "filtering with conditions in has_many relations" do

    it "filters _some on has_many" do
     @query = %{
       query {
         accounts(where: {
           stringField: "bob",
           labels_some: { amount: 2, name: "a" }
         }) {
           id
           labels {
             id
           }
         }
       }
     }

     expect(subject.size).to eq(1)
     expect(subject[0]["id"]).to eq a0.id.to_s
     expect(subject[0]["labels"][0]["id"]).to eq l0.id.to_s
     expect(subject[0]["labels"][1]["id"]).to eq l1.id.to_s
    end

    it "filters _none on has_many" do
     @query = %{
       query {
         accounts(where: {
           labels_none: { amount: 2 }
         }) {
           id
           labels {
             id
           }
         }
       }
     }

     expect(subject.size).to eq(1)
     expect(subject[0]["id"]).to eq a2.id.to_s
     expect(subject[0]["labels"][0]["id"]).to eq l4.id.to_s
     expect(subject[0]["labels"][1]["id"]).to eq l5.id.to_s
    end

    it "filters _every on has_many" do
     @query = %{
       query {
         accounts(where: {
           labels_every: { name: "a" }
         }) {
           id
           labels {
             id
           }
         }
       }
     }

     if ENV['DRIVER'] == "mongo"
       # TODO: build the _every division for mongoid
       pending
       fail
     end

     expect(subject.size).to eq(2)
     expect(subject[0]["id"]).to eq a0.id.to_s
     expect(subject[0]["labels"][0]["id"]).to eq l0.id.to_s
     expect(subject[0]["labels"][1]["id"]).to eq l1.id.to_s
     
     expect(subject[1]["id"]).to eq a1.id.to_s
     expect(subject[1]["labels"][0]["id"]).to eq l2.id.to_s
     expect(subject[1]["labels"][1]["id"]).to eq l3.id.to_s
    end
  end
end
