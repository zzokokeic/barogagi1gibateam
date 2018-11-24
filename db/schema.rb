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

ActiveRecord::Schema.define(version: 2018_11_11_150927) do

  create_table "animals", force: :cascade do |t|
    t.string "still_image"
    t.string "moving_image"
    t.integer "coin_price"
    t.integer "max_step"
  end

  create_table "coinpayments", force: :cascade do |t|
    t.integer "user_id"
    t.integer "cash_amount"
    t.integer "coin_amount"
    t.datetime "created_at"
  end

  create_table "devices", force: :cascade do |t|
    t.integer "user_id"
    t.string "token"
    t.datetime "created_at"
  end

  create_table "habits", force: :cascade do |t|
    t.string "mission"
    t.string "category"
  end

  create_table "myanimals", force: :cascade do |t|
    t.integer "user_id"
    t.integer "animal_id"
    t.integer "habit_id"
    t.integer "coin_paid"
    t.integer "growth_step"
    t.boolean "upgrade_done"
    t.boolean "is_deleted"
    t.datetime "created_at"
  end

  create_table "notices", force: :cascade do |t|
    t.string "content"
    t.string "category"
    t.datetime "created_at"
  end

  create_table "upgrades", force: :cascade do |t|
    t.integer "myanimal_id"
    t.integer "growth_step"
    t.datetime "created_at"
  end

  create_table "users", force: :cascade do |t|
    t.string "nickname"
    t.string "email"
    t.string "password"
    t.string "upgrade_password"
    t.integer "current_coin"
    t.integer "max_myanimal"
    t.datetime "created_at"
  end

end
