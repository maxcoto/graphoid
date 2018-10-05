require 'rails_helper'

describe "QueryHasManyThrough", :type => :request do
  next if ENV['DRIVER'] == "mongo"
  
  let!(:delete) { Contract.delete_all; Player.delete_all; Team.delete_all; }
  subject { Helper.resolve(self, "players", @query) }

  let!(:p0) { Player.create!(name: 'ba') }
  let!(:p1) { Player.create!(name: 'be') }
  let!(:p2) { Player.create!(name: 'bi') }

  let!(:t0) { Team.create!(name: 'ba') }
  let!(:t1) { Team.create!(name: 'be') }
  let!(:t2) { Team.create!(name: 'bu') }
  
  before do
    p0.update!(teams: [t0, t1])
    p1.update!(teams: [t1, t2])
    p2.update!(teams: [t2, t0])
  end

  describe "filtering has_many through relations" do
    it "filters _some" do
      @query = %{
        query {
          players(where: { teams_some: { name: "bu" } }){
            id
            teams(order: { id: ASC }) {
              id
              players(where: { name_in: ["be", "bi"] }) {
                id
              }
            }
          }
        }
      }

      expect(subject.size).to eq(2)

      expect(subject[0]["id"]).to eq p1.id.to_s
      expect(subject[0]["teams"][0]["id"]).to eq t1.id.to_s
      expect(subject[0]["teams"][0]["players"][0]["id"]).to eq p1.id.to_s
      expect(subject[0]["teams"][1]["id"]).to eq t2.id.to_s      
      expect(subject[0]["teams"][1]["players"][0]["id"]).to eq p1.id.to_s
      expect(subject[0]["teams"][1]["players"][1]["id"]).to eq p2.id.to_s

      expect(subject[1]["id"]).to eq p2.id.to_s
      expect(subject[1]["teams"][0]["id"]).to eq t0.id.to_s
      expect(subject[1]["teams"][0]["players"][0]["id"]).to eq p2.id.to_s
      expect(subject[1]["teams"][1]["id"]).to eq t2.id.to_s      
      expect(subject[1]["teams"][1]["players"][0]["id"]).to eq p1.id.to_s
      expect(subject[1]["teams"][1]["players"][1]["id"]).to eq p2.id.to_s
    end
  end
end
