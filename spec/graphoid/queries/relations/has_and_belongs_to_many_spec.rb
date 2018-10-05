require 'rails_helper'

describe "QueryHasAndBelongsToMany", :type => :request do
  let!(:delete) { User.delete_all; Account.delete_all; }
  subject { Helper.resolve(self, "users", @query) }

  let!(:u0) { User.create!(name: 'ba') }
  let!(:u1) { User.create!(name: 'be') }
  let!(:u2) { User.create!(name: 'bi') }

  let!(:a0) { Account.create!(snake_case: 'ba') }
  let!(:a1) { Account.create!(snake_case: 'be') }
  let!(:a2) { Account.create!(snake_case: 'bu') }
  
  before do
    u0.update!(accounts: [a0, a1])
    u1.update!(accounts: [a1, a2])
    u2.update!(accounts: [a2, a0])
  end

  describe "filtering has_and_belongs_to_many relations" do
    it "filters _some" do
      @query = %{
        query {
          users(where: { accounts_some: { snakeCase: "bu" } }){
            id
            accounts(order: { id: ASC }) {
              id
              users(where: { name_in: ["be", "bi"] }) {
                id
              }
            }
          }
        }
      }

      expect(subject.size).to eq(2)

      expect(subject[0]["id"]).to eq u1.id.to_s
      expect(subject[0]["accounts"][0]["id"]).to eq a1.id.to_s
      expect(subject[0]["accounts"][0]["users"][0]["id"]).to eq u1.id.to_s
      expect(subject[0]["accounts"][1]["id"]).to eq a2.id.to_s      
      expect(subject[0]["accounts"][1]["users"][0]["id"]).to eq u1.id.to_s
      expect(subject[0]["accounts"][1]["users"][1]["id"]).to eq u2.id.to_s

      expect(subject[1]["id"]).to eq u2.id.to_s
      expect(subject[1]["accounts"][0]["id"]).to eq a0.id.to_s
      expect(subject[1]["accounts"][0]["users"][0]["id"]).to eq u2.id.to_s
      expect(subject[1]["accounts"][1]["id"]).to eq a2.id.to_s      
      expect(subject[1]["accounts"][1]["users"][0]["id"]).to eq u1.id.to_s
      expect(subject[1]["accounts"][1]["users"][1]["id"]).to eq u2.id.to_s
    end
  end
end
