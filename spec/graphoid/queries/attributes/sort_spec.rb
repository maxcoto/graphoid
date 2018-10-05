require 'rails_helper'

describe "QuerySorted", :type => :request do

  let!(:delete) { Account.delete_all }

  let!(:yesterday) { DateTime.yesterday.to_time.iso8601 }
  let!(:today)     { DateTime.now.iso8601 }
  let!(:tomorrow)  { DateTime.tomorrow.to_time.iso8601 }

  let!(:a0) { Account.create!(integer_field: 4, float_field: 4.4, string_field: 'bog', snake_case: 'snakg', camelCase: 'camog', datetime_field: today )}
  let!(:a1) { Account.create!(integer_field: 3, float_field: 4.3, string_field: 'boc', snake_case: 'snakc', camelCase: 'camoc', datetime_field: tomorrow )}
  let!(:a2) { Account.create!(integer_field: 4, float_field: 4.1, string_field: 'boa', snake_case: 'snaka', camelCase: 'camoa', datetime_field: yesterday )}
  let!(:a3) { Account.create!(integer_field: 5, float_field: 4.5, string_field: 'bod', snake_case: 'snakd', camelCase: 'camod', datetime_field: today )}
  let!(:a4) { Account.create!(integer_field: 4, float_field: 4.2, string_field: 'boe', snake_case: 'snake', camelCase: 'camee', datetime_field: today )}
  let!(:a5) { Account.create!(integer_field: 0, float_field: 4.0, string_field: 'bof', snake_case: 'snakf', camelCase: 'camef', datetime_field: tomorrow )}
  let!(:a6) { Account.create!(integer_field: 6, float_field: 4.6, string_field: 'bob', snake_case: 'snakb', camelCase: 'cameb', datetime_field: yesterday )}

  let!(:accounts) { Account.all.to_a }

  it "sorts objects by every field" do
    (Graphoid::Attribute.fields_of(Account) - Account.graphields).each do |field|
      # TODO: array and hash sorting does not work
      next if [Array, Hash].include?(field.type)

      camelized_field = field.name.camelize.camelize(:lower).to_s

      ["ASC", "DESC"].each do |order|
        query = %{
          query {
            accounts(order: { #{camelized_field}: #{order} } ) {
              #{camelized_field}
            }
          }
        }

        result = Helper.resolve(self, "accounts", query).map { |account| account[camelized_field]  }
        list = accounts.map(&:"#{field.name}")
        list.map!(&:to_s) if field.type == BSON::ObjectId || field.name == "id"
        clock_options = [:datetime, :date, :time, :timestamp, DateTime, Date, Time]

        if clock_options.include?(field.type)
          list.map!{ |m| m.to_s.first(19).sub(' ', 'T') }
          result.map!{ |r| r.first(19) }
        end

        list.sort!
        list.reverse! if order == "DESC"

        expect(result).to eq(list)
      end
    end
  end

  it "sorts by many fields" do
    query = %{
      query {
        accounts(order: { integerField: ASC, stringField: DESC } ) {
          id
          integerField
          stringField
        }
      }
    }

    result = Helper.resolve(self, "accounts", query).map { |account| account["id"]  }
    expect(result).to eq Helper.ids_of(a5, a1, a0, a4, a2, a3, a6)
  end
end
