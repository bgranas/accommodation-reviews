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

ActiveRecord::Schema.define(version: 20170415220823) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "booking_properties", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "hw_facilities", force: :cascade do |t|
    t.integer  "hw_property_id"
    t.string   "facility"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["hw_property_id"], name: "index_hw_facilities_on_hw_property_id", using: :btree
  end

  create_table "hw_images", force: :cascade do |t|
    t.integer  "hw_property_id"
    t.string   "image_size"
    t.string   "url"
    t.integer  "height"
    t.integer  "width"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["hw_property_id"], name: "index_hw_images_on_hw_property_id", using: :btree
  end

  create_table "hw_properties", force: :cascade do |t|
    t.integer  "provider_id"
    t.string   "name"
    t.decimal  "overall_rating"
    t.integer  "review_count"
    t.decimal  "value_rating"
    t.decimal  "security_rating"
    t.decimal  "location_rating"
    t.decimal  "staff_rating"
    t.decimal  "atmosphere_rating"
    t.decimal  "cleanliness_rating"
    t.decimal  "facilities_rating"
    t.string   "address"
    t.string   "phone"
    t.string   "city"
    t.integer  "provider_city_id"
    t.string   "country"
    t.integer  "provider_country_id"
    t.string   "property_type"
    t.text     "description"
    t.string   "base_currency"
    t.decimal  "lat"
    t.decimal  "lng"
    t.string   "directions"
    t.decimal  "star_rating"
    t.integer  "deposit_percent"
    t.datetime "creation_date"
    t.integer  "max_people_per_booking"
    t.integer  "min_dorm_price"
    t.integer  "min_private_price"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "reviews", force: :cascade do |t|
    t.integer  "hw_property_id"
    t.integer  "review_id"
    t.string   "username"
    t.string   "nationality"
    t.string   "gender"
    t.string   "age"
    t.integer  "num_reviews"
    t.text     "text"
    t.datetime "date"
    t.decimal  "overall_rating"
    t.decimal  "value"
    t.decimal  "security"
    t.decimal  "location"
    t.decimal  "facilities"
    t.decimal  "staff"
    t.decimal  "atmosphere"
    t.decimal  "cleanliness"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["hw_property_id"], name: "index_reviews_on_hw_property_id", using: :btree
  end

  create_table "room_availabilities", force: :cascade do |t|
    t.integer  "hw_property_id"
    t.integer  "room_id"
    t.integer  "available_beds"
    t.datetime "checkin_date"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["hw_property_id"], name: "index_room_availabilities_on_hw_property_id", using: :btree
  end

  create_table "room_types", force: :cascade do |t|
    t.integer  "hw_property_id"
    t.integer  "room_id"
    t.integer  "num_beds"
    t.string   "room_category"
    t.string   "room_subtype"
    t.decimal  "price"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["hw_property_id"], name: "index_room_types_on_hw_property_id", using: :btree
  end

end
