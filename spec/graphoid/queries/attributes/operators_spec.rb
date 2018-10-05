require 'rails_helper'

describe "QueryWithOperators", :type => :request do
  let!(:delete) { Account.delete_all }
  subject { Helper.resolve(self, "accounts", @query).map { |a| a["id"] } }

  let!(:three_days_ago) { 3.days.ago.to_time.iso8601 }
  let!(:two_days_ago) { 2.days.ago.to_time.iso8601 }
  let!(:yesterday) { DateTime.yesterday.iso8601 }
  let!(:today) { DateTime.now.iso8601 }
  let!(:tomorrow) { DateTime.tomorrow.to_time.iso8601 }
  let!(:day_after_tomorrow) { 2.days.from_now.to_time.iso8601 }

  let!(:a0) { Account.create!(integer_field: 1, float_field: 1.3, string_field: 'a', camelCase: 'a', datetime_field: three_days_ago )}
  let!(:a1) { Account.create!(integer_field: 2, float_field: 2.3, string_field: 'b', camelCase: 'b', datetime_field: two_days_ago )}
  let!(:a2) { Account.create!(integer_field: 3, float_field: 3.2, string_field: 'c', camelCase: 'c', datetime_field: yesterday )}
  let!(:a3) { Account.create!(integer_field: 4, float_field: 4.3, string_field: 'd', camelCase: 'd', datetime_field: today )}
  let!(:a4) { Account.create!(integer_field: 5, float_field: 5.3, string_field: 'e', camelCase: 'e', datetime_field: tomorrow )}
  let!(:a5) { Account.create!(integer_field: 6, float_field: 6.2, string_field: 'f', camelCase: 'f', datetime_field: tomorrow )}
  let!(:a6) { Account.create!(integer_field: 7, float_field: 7.2, string_field: 'g', camelCase: 'g', datetime_field: day_after_tomorrow )}

  describe "filtering using operators" do
    context "gte and lte" do
      it "with numbers" do
        @query = %{
          query {
            accounts(where: { OR: [ { integerField_gte: 6 }, { floatField_lte: 2.3 } ] }) {
              id
            }
          }
        }

        expect(subject).to eq Helper.ids_of(a0, a1, a5, a6)
      end
      
      it "with strings" do
        @query = %{
          query {
            accounts(where: { OR: [ { stringField_gte: "f" }, { camelCase_lte: "b" } ] }) {
              id
            }
          }
        }

        expect(subject).to eq Helper.ids_of(a0, a1, a5, a6)
      end
      
      it "with dates" do
        @query = %{
          query {
            accounts(where: { OR: [ { datetimeField_gte: "#{tomorrow}" }, { datetimeField_lte: "#{two_days_ago}" } ] }) {
              id
            }
          }
        }

        expect(subject).to eq Helper.ids_of(a0, a1, a4, a5, a6)
      end
    end
    
    context "gt and lt" do
      it "with numbers" do
        @query = %{
          query {
            accounts(where: { OR: [ { integerField_gt: 6 }, { floatField_lt: 2.0 } ] }) {
              id
            }
          }
        }

        expect(subject).to eq Helper.ids_of(a0, a6)
      end
      
      it "with strings" do
        @query = %{
          query {
            accounts(where: { OR: [ { stringField_gt: "f" }, { camelCase_lt: "b" } ] }) {
              id
            }
          }
        }

        expect(subject).to eq Helper.ids_of(a0, a6)
      end
      
      it "with dates" do
        @query = %{
          query {
            accounts(where: { OR: [ { datetimeField_gt: "#{tomorrow}" }, { datetimeField_lt: "#{two_days_ago}" } ] }) {
              id
            }
          }
        }

        expect(subject).to eq Helper.ids_of(a0, a6)
      end
    end
  end
end
