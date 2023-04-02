# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180921152014) do

  create_table "accounts", force: :cascade do |t|
    t.integer "house_id"
    t.integer "forbidden"
    t.integer "integer_field"
    t.string "string_field"
    t.float "float_field"
    t.string "snake_case"
    t.string "camelCase"
    t.datetime "datetime_field"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.index ["house_id"], name: "index_accounts_on_house_id"
  end

  create_table "accounts_users", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "account_id"
    t.index ["account_id"], name: "index_accounts_users_on_account_id"
    t.index ["user_id"], name: "index_accounts_users_on_user_id"
  end

  create_table "brains", force: :cascade do |t|
    t.string "name"
    t.integer "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["person_id"], name: "index_brains_on_person_id"
  end

  create_table "contracts", force: :cascade do |t|
    t.integer "team_id"
    t.integer "player_id"
  end

  create_table "employees", force: :cascade do |t|
    t.string "name"
    t.integer "manager_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "follows", force: :cascade do |t|
    t.integer "follower_id"
    t.integer "followee_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "houses", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "labels", force: :cascade do |t|
    t.string "name"
    t.float "amount"
    t.integer "account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_labels_on_account_id"
  end

  create_table "people", force: :cascade do |t|
    t.integer "account_id"
    t.string "snake_case"
    t.string "camelCase"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_people_on_account_id"
  end

  create_table "players", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "teams", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
