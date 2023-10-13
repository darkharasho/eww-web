# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2023_10_13_051858) do
  create_table "arcdps", force: :cascade do |t|
    t.datetime "last_updated_at", precision: nil, null: false
  end

  create_table "attendance", force: :cascade do |t|
    t.integer "member_id", null: false
    t.string "raid_type", limit: 255, null: false
    t.datetime "date", precision: nil, null: false
    t.index ["member_id"], name: "attendance_member_id"
  end

  create_table "config", force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.integer "guild_id", null: false
    t.json "value", null: false
    t.text "value_type", null: false
    t.index ["name"], name: "config_name", unique: true
  end

  create_table "feed", force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.integer "guild_id", null: false
    t.string "modified", limit: 255, null: false
    t.index ["name"], name: "feed_name", unique: true
  end

  create_table "guilds", force: :cascade do |t|
    t.string "uid", default: "", null: false
    t.string "name", default: "", null: false
    t.string "remote_image_url", default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "member", force: :cascade do |t|
    t.string "username", limit: 255, null: false
    t.integer "guild_id", null: false
    t.integer "discord_id", null: false
    t.string "gw2_api_key", limit: 255
    t.json "gw2_stats"
    t.string "gw2_username", limit: 255
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil
    t.integer "user_id"
    t.index ["discord_id"], name: "member_discord_id", unique: true
    t.index ["gw2_api_key"], name: "member_gw2_api_key", unique: true
    t.index ["username"], name: "member_username", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "username", default: "", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "provider", default: "", null: false
    t.string "uid", default: "", null: false
    t.string "remote_image_url", default: ""
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "auth_token"
    t.datetime "auth_expiration"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "attendance", "member"
end
