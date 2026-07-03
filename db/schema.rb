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

ActiveRecord::Schema[8.1].define(version: 2026_07_03_213354) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "courses", force: :cascade do |t|
    t.string "age_group"
    t.string "category"
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "duration"
    t.string "level"
    t.integer "max_students"
    t.string "name"
    t.decimal "price"
    t.bigint "school_id", null: false
    t.bigint "teacher_id", null: false
    t.datetime "updated_at", null: false
    t.index ["school_id"], name: "index_courses_on_school_id"
    t.index ["teacher_id"], name: "index_courses_on_teacher_id"
  end

  create_table "invitations", force: :cascade do |t|
    t.datetime "accepted_at"
    t.datetime "created_at", null: false
    t.string "email"
    t.datetime "expired_at"
    t.bigint "school_id", null: false
    t.datetime "sent_at"
    t.string "token"
    t.datetime "updated_at", null: false
    t.index ["school_id"], name: "index_invitations_on_school_id"
  end

  create_table "reservations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "schedule_id", null: false
    t.string "status"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["schedule_id"], name: "index_reservations_on_schedule_id"
    t.index ["user_id"], name: "index_reservations_on_user_id"
  end

  create_table "schedules", force: :cascade do |t|
    t.bigint "course_id", null: false
    t.datetime "created_at", null: false
    t.time "end_time"
    t.string "room"
    t.time "start_time"
    t.bigint "teacher_id", null: false
    t.datetime "updated_at", null: false
    t.integer "weekday"
    t.index ["course_id"], name: "index_schedules_on_course_id"
    t.index ["teacher_id"], name: "index_schedules_on_teacher_id"
  end

  create_table "schools", force: :cascade do |t|
    t.text "address"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "email"
    t.string "name"
    t.string "phone"
    t.datetime "updated_at", null: false
    t.string "website"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "courses", "schools"
  add_foreign_key "courses", "users", column: "teacher_id"
  add_foreign_key "invitations", "schools"
  add_foreign_key "reservations", "schedules"
  add_foreign_key "reservations", "users"
  add_foreign_key "schedules", "courses"
  add_foreign_key "schedules", "users", column: "teacher_id"
end
