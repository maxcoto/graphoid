ActiveRecord::Schema.define do
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

  create_table "contracts", force: true do |t|
   t.integer "team_id"
   t.integer "player_id"
 end

  create_table "players", force: true do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "teams", force: true do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "employees", force: true do |t|
    t.string "name"
    t.integer "manager_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "follows", force: true do |t|
    t.integer  "follower_id"
    t.integer  "followee_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end
  
  create_table :accounts_users, id: false do |t|
    t.belongs_to :user, index: true
    t.belongs_to :account, index: true
  end
  
  create_table "brains", force: true do |t|
    t.string "name"
    t.belongs_to :person, index: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end
end
