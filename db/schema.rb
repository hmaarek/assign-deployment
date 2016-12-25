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

ActiveRecord::Schema.define(version: 20161224111900) do

  create_table "backhauls", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "rfs_status", limit: 255
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.text     "descript",   limit: 65535
    t.integer  "bkh_type",   limit: 4
    t.integer  "ring_id",    limit: 4
  end

  create_table "bkh_conn_inters", force: :cascade do |t|
    t.integer  "bkh_id",     limit: 4
    t.integer  "conn_id",    limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "cables", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.integer  "size",          limit: 4
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "location_a_id", limit: 4
    t.integer  "location_b_id", limit: 4
    t.integer  "backhaul_id",   limit: 4
  end

  create_table "connections", force: :cascade do |t|
    t.string   "name",             limit: 255
    t.integer  "customer_id",      limit: 4
    t.string   "status",           limit: 255
    t.text     "description",      limit: 65535
    t.string   "request_category", limit: 255
    t.string   "request_id",       limit: 255
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.integer  "backhaul_id",      limit: 4
    t.string   "fiber_type",       limit: 255
  end

  create_table "contracts", force: :cascade do |t|
    t.string   "contract_name", limit: 255
    t.integer  "customer_id",   limit: 4
    t.date     "signed_date"
    t.date     "expiring_date"
    t.text     "description",   limit: 65535
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "customers", force: :cascade do |t|
    t.string   "name",                limit: 255
    t.string   "contact_name",        limit: 255
    t.string   "contact_title",       limit: 255
    t.string   "contact_phone",       limit: 255
    t.text     "notes",               limit: 65535
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.string   "avatar_file_name",    limit: 255
    t.string   "avatar_content_type", limit: 255
    t.integer  "avatar_file_size",    limit: 4
    t.datetime "avatar_updated_at"
  end

  create_table "devices", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "device_type", limit: 255
    t.integer  "net_rack_id", limit: 4
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "devices", ["net_rack_id"], name: "index_devices_on_net_rack_id", using: :btree

  create_table "devports", force: :cascade do |t|
    t.string   "name",         limit: 255
    t.integer  "fiber_in_id",  limit: 4
    t.integer  "fiber_out_id", limit: 4
    t.integer  "device_id",    limit: 4
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.integer  "location_id",  limit: 4
  end

  add_index "devports", ["device_id"], name: "index_devports_on_device_id", using: :btree

  create_table "fiberstrands", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.integer  "porta",         limit: 4
    t.integer  "portb",         limit: 4
    t.integer  "cable_id",      limit: 4
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "location_id",   limit: 4
    t.integer  "connection_id", limit: 4
  end

  add_index "fiberstrands", ["cable_id"], name: "index_fiberstrands_on_cable_id", using: :btree

  create_table "locations", force: :cascade do |t|
    t.string   "name",           limit: 255
    t.string   "address",        limit: 255
    t.string   "location_type",  limit: 255
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.string   "rfs_status",     limit: 255
    t.date     "rfs_date"
    t.integer  "home_passed",    limit: 4
    t.integer  "home_connected", limit: 4
  end

  create_table "net_racks", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.integer  "size",        limit: 4
    t.integer  "location_id", limit: 4
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "rack_type",   limit: 4
  end

  add_index "net_racks", ["location_id"], name: "index_net_racks_on_location_id", using: :btree

  create_table "rings", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.text     "description", limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.string   "email",           limit: 255
    t.string   "password_digest", limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "user_type",       limit: 4
  end

end
