# frozen_string_literal: true

require 'rails_helper'

describe 'QueryHasAndBelongsToManySelves', type: :request do
  let!(:delete) { User.delete_all; }
  subject { Helper.resolve(self, 'users', @query) }

  if ENV['DRIVER'] == 'mongo'
    let!(:u0) { User.create!(name: 'ba') }
    let!(:u1) { User.create!(name: 'be') }
    let!(:u2) { User.create!(name: 'bi') }
    let!(:u3) { User.create!(name: 'bu', dependents: [u0]) } # this creates a dependency on u0
    let!(:u4) { User.create!(name: 'bo', dependencies: [u1]) }
    let!(:u5) { User.create!(name: 'bh', dependencies: [u3, u4], dependents: [u2]) }
  else # active record
    let!(:u0) { User.create!(name: 'ba') }
    let!(:u1) { User.create!(name: 'be') }
    let!(:u2) { User.create!(name: 'bi') }
    let!(:u3) { User.create!(name: 'bu') }
    let!(:u4) { User.create!(name: 'bo') }
    let!(:u5) { User.create!(name: 'bh') }
    let!(:f0) { Follow.create!(follower: u3, followee: u0) }
    let!(:f0) { Follow.create!(follower: u4, followee: u1) }
    let!(:f0) { Follow.create!(follower: u5, followee: u3) }
    let!(:f0) { Follow.create!(follower: u5, followee: u4) }
    let!(:f0) { Follow.create!(follower: u2, followee: u5) }
  end

  describe 'filtering has_and_belongs_to_many relations' do
    it 'filters _some in mongoid' do
      @query = %{
        query {
          users(where: {
            dependencies_some: { name: "bu" }
          }) {
            id
            dependencies {
              id
              dependents {
                id
              }
            }
          }
        }
      }

      if ENV['DRIVER'] == 'mongo'
        expect(subject.size).to eq(2)
        expect(subject[0]['id']).to eq u0.id.to_s
        expect(subject[0]['dependencies'][0]['id']).to eq u3.id.to_s
        expect(subject[0]['dependencies'][0]['dependents'][0]['id']).to eq u0.id.to_s

        expect(subject[1]['id']).to eq u5.id.to_s
        expect(subject[1]['dependencies'][0]['id']).to eq u3.id.to_s
        expect(subject[1]['dependencies'][0]['dependents'][0]['id']).to eq u0.id.to_s

        expect(subject[1]['dependencies'][1]['id']).to eq u4.id.to_s
        expect(subject[1]['dependencies'][1]['dependents'][0]['id']).to eq u5.id.to_s
      end
    end

    it 'filters _some in active record' do
      @query = %{
        query {
          users(where: {
            followers_some: { name: "bu" }
          }) {
            id
            followers {
              id
              followees {
                id
              }
            }
          }
        }
      }

      if ENV['DRIVER'] != 'mongo'
        # TODO
        pending('not working yet - needs more brain cells')
        raise

        expect(subject.size).to eq(2)
        expect(subject[0]['id']).to eq u0.id.to_s
        expect(subject[0]['followers'][0]['id']).to eq u3.id.to_s
        expect(subject[0]['followers'][0]['followees'][0]['id']).to eq u0.id.to_s

        expect(subject[1]['id']).to eq u5.id.to_s
        expect(subject[1]['followers'][0]['id']).to eq u3.id.to_s
        expect(subject[1]['followers'][0]['followees'][0]['id']).to eq u0.id.to_s

        expect(subject[1]['followers'][1]['id']).to eq u4.id.to_s
        expect(subject[1]['followers'][1]['followees'][0]['id']).to eq u5.id.to_s
      end
    end
  end
end
