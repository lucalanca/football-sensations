# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20150106011358) do

  create_table "competitions", force: :cascade do |t|
    t.string "name", null: false
  end

  create_table "goals", force: :cascade do |t|
    t.string   "result"
    t.integer  "match_id"
    t.string   "scorer"
    t.string   "minute"
    t.boolean  "own_goal"
    t.boolean  "penalty"
    t.boolean  "assist"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "matches", force: :cascade do |t|
    t.integer  "home_team_id",                    null: false
    t.integer  "away_team_id",                    null: false
    t.datetime "kickoff"
    t.string   "result",          default: "0-0", null: false
    t.string   "home_form"
    t.string   "away_form"
    t.integer  "fixture"
    t.string   "highlight_video"
    t.integer  "competition_id"
    t.string   "stadium"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  add_index "matches", ["away_team_id"], name: "index_matches_on_away_team_id"
  add_index "matches", ["competition_id"], name: "index_matches_on_competition_id"
  add_index "matches", ["home_team_id"], name: "index_matches_on_home_team_id"

  create_table "teams", force: :cascade do |t|
    t.string "name", null: false
  end

end
