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

ActiveRecord::Schema[8.0].define(version: 2025_07_10_203138) do
  create_table "games", force: :cascade do |t|
    t.string "auth_token"
    t.string "name"
    t.integer "active_player"
    t.string "community_cards"
    t.integer "pot"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "deck"
    t.integer "bet"
    t.integer "dealer"
    t.integer "raise_opportunities"
    t.string "winners"
  end

  create_table "player_requests", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "game_id", null: false
    t.string "auth_token"
    t.index ["auth_token"], name: "index_player_requests_on_auth_token", unique: true
    t.index ["game_id"], name: "index_player_requests_on_game_id"
  end

  create_table "players", force: :cascade do |t|
    t.string "name"
    t.integer "chips"
    t.string "hole_cards"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "game_id", null: false
    t.string "auth_token"
    t.integer "bet"
    t.integer "fold"
    t.integer "kick"
    t.index ["auth_token"], name: "index_players_on_auth_token", unique: true
    t.index ["game_id"], name: "index_players_on_game_id"
  end

  add_foreign_key "player_requests", "games"
  add_foreign_key "players", "games"
end
