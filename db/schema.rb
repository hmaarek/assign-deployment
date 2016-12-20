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

ActiveRecord::Schema.define(version: 20161127104754) do

  create_table "backhauls", force: :cascade do |t|
    t.string   "name"
    t.string   "rfs_status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text     "descript"
    t.integer  "bkh_type"
    t.integer  "ring_id"
  end

  create_table "bkh_conn_inters", force: :cascade do |t|
    t.integer  "bkh_id"
    t.integer  "conn_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cables", force: :cascade do |t|
    t.string   "name"
    t.integer  "size"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "location_a_id"
    t.integer  "location_b_id"
    t.integer  "backhaul_id"
  end

  create_table "connections", force: :cascade do |t|
    t.string   "name"
    t.integer  "customer_id"
    t.string   "status"
    t.string   "description"
    t.string   "request_category"
    t.string   "request_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.integer  "backhaul_id"
    t.string   "fiber_type"
  end

  create_table "contracts", force: :cascade do |t|
    t.string   "contract_name"
    t.integer  "customer_id"
    t.date     "signed_date"
    t.date     "expiring_date"
    t.text     "description"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "customers", force: :cascade do |t|
    t.string   "name"
    t.string   "contact_name"
    t.string   "contact_title"
    t.string   "contact_phone"
    t.text     "notes"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
  end

  create_table "devices", force: :cascade do |t|
    t.string   "name"
    t.string   "device_type"
    t.integer  "net_rack_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "devices", ["net_rack_id"], name: "index_devices_on_net_rack_id"

  create_table "devports", force: :cascade do |t|
    t.string   "name"
    t.integer  "fiber_in_id"
    t.integer  "fiber_out_id"
    t.integer  "device_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "location_id"
  end

  add_index "devports", ["device_id"], name: "index_devports_on_device_id"

  create_table "fiberstrands", force: :cascade do |t|
    t.string   "name"
    t.integer  "porta"
    t.integer  "portb"
    t.integer  "cable_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "location_id"
    t.integer  "connection_id"
  end

  add_index "fiberstrands", ["cable_id"], name: "index_fiberstrands_on_cable_id"

  create_table "locations", force: :cascade do |t|
    t.string   "name"
    t.string   "address"
    t.string   "location_type"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.string   "rfs_status"
    t.date     "rfs_date"
    t.integer  "home_passed"
    t.integer  "home_connected"
  end

  create_table "net_racks", force: :cascade do |t|
    t.string   "name"
    t.integer  "size"
    t.integer  "location_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "rack_type"
  end

  add_index "net_racks", ["location_id"], name: "index_net_racks_on_location_id"

  create_table "rings", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.string   "password_digest"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "user_type"
  end

end
