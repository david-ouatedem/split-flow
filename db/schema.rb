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

ActiveRecord::Schema[8.1].define(version: 2026_03_06_084919) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "collaborations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "project_id", null: false
    t.string "role"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["project_id"], name: "index_collaborations_on_project_id"
    t.index ["user_id", "project_id"], name: "index_collaborations_on_user_id_and_project_id", unique: true
    t.index ["user_id"], name: "index_collaborations_on_user_id"
  end

  create_table "project_files", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "label", null: false
    t.string "name", null: false
    t.bigint "project_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "uploader_id", null: false
    t.integer "version", default: 1, null: false
    t.index ["created_at"], name: "index_project_files_on_created_at"
    t.index ["project_id", "label", "version"], name: "index_project_files_on_project_id_and_label_and_version", unique: true
    t.index ["project_id"], name: "index_project_files_on_project_id"
    t.index ["uploader_id"], name: "index_project_files_on_uploader_id"
  end

  create_table "projects", force: :cascade do |t|
    t.integer "bpm"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "genre"
    t.bigint "owner_id", null: false
    t.integer "status", default: 0, null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.integer "visibility", default: 0, null: false
    t.index ["owner_id"], name: "index_projects_on_owner_id"
    t.index ["status"], name: "index_projects_on_status"
    t.index ["visibility"], name: "index_projects_on_visibility"
  end

  create_table "split_agreements", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "locked_at"
    t.bigint "project_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.string "verification_token", null: false
    t.index ["project_id"], name: "index_split_agreements_on_project_id", unique: true
    t.index ["status"], name: "index_split_agreements_on_status"
    t.index ["verification_token"], name: "index_split_agreements_on_verification_token", unique: true
  end

  create_table "split_entries", force: :cascade do |t|
    t.datetime "approved_at"
    t.datetime "created_at", null: false
    t.decimal "percentage", precision: 5, scale: 2, null: false
    t.bigint "split_agreement_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["approved_at"], name: "index_split_entries_on_approved_at"
    t.index ["split_agreement_id", "user_id"], name: "index_split_entries_on_split_agreement_id_and_user_id", unique: true
    t.index ["split_agreement_id"], name: "index_split_entries_on_split_agreement_id"
    t.index ["user_id"], name: "index_split_entries_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.text "bio"
    t.datetime "created_at", null: false
    t.string "display_name"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.jsonb "portfolio_urls", default: {}
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "role"
    t.string "skills", default: [], array: true
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["portfolio_urls"], name: "index_users_on_portfolio_urls", using: :gin
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["skills"], name: "index_users_on_skills", using: :gin
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "collaborations", "projects"
  add_foreign_key "collaborations", "users"
  add_foreign_key "project_files", "projects"
  add_foreign_key "project_files", "users", column: "uploader_id"
  add_foreign_key "projects", "users", column: "owner_id"
  add_foreign_key "split_agreements", "projects"
  add_foreign_key "split_entries", "split_agreements"
  add_foreign_key "split_entries", "users"
end
