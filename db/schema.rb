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

ActiveRecord::Schema.define(version: 20150425193229) do

  create_table "gamas", force: :cascade do |t|
    t.boolean  "pending"
    t.boolean  "done"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "name"
    t.integer  "limit"
    t.text     "manager"
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "password_digest"
    t.boolean  "logged"
    t.string   "remember_hash"
    t.boolean  "admin"
    t.boolean  "host"
    t.integer  "gama_id"
    t.string   "channel"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["gama_id"], name: "index_users_on_gama_id"

end
