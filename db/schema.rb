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

ActiveRecord::Schema[7.2].define(version: 2026_05_20_211440) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "clients", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "company"
    t.text "address"
    t.string "phone"
    t.text "notes"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_clients_on_user_id"
  end

  create_table "expenses", force: :cascade do |t|
    t.string "description", null: false
    t.decimal "amount", precision: 12, scale: 2, default: "0.0", null: false
    t.integer "category", default: 0, null: false
    t.date "date", null: false
    t.string "currency", default: "USD", null: false
    t.boolean "billable", default: false, null: false
    t.bigint "project_id"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_expenses_on_category"
    t.index ["date"], name: "index_expenses_on_date"
    t.index ["project_id"], name: "index_expenses_on_project_id"
    t.index ["user_id"], name: "index_expenses_on_user_id"
  end

  create_table "invoice_items", force: :cascade do |t|
    t.string "description", null: false
    t.decimal "quantity", precision: 12, scale: 2, default: "1.0"
    t.decimal "unit_price", precision: 12, scale: 2, default: "0.0"
    t.decimal "total", precision: 12, scale: 2, default: "0.0"
    t.integer "position", default: 0
    t.bigint "invoice_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invoice_id"], name: "index_invoice_items_on_invoice_id"
  end

  create_table "invoices", force: :cascade do |t|
    t.string "invoice_number", null: false
    t.integer "status", default: 0, null: false
    t.date "issue_date"
    t.date "due_date"
    t.text "notes"
    t.text "terms"
    t.string "currency", default: "USD", null: false
    t.decimal "tax_rate", precision: 5, scale: 2, default: "0.0"
    t.decimal "discount", precision: 12, scale: 2, default: "0.0"
    t.decimal "subtotal", precision: 12, scale: 2, default: "0.0"
    t.decimal "total", precision: 12, scale: 2, default: "0.0"
    t.decimal "amount_paid", precision: 12, scale: 2, default: "0.0"
    t.boolean "recurring", default: false, null: false
    t.integer "recurring_interval"
    t.date "recurring_next_run"
    t.bigint "parent_invoice_id"
    t.datetime "sent_at"
    t.datetime "paid_at"
    t.bigint "client_id", null: false
    t.bigint "project_id"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "public_token"
    t.index ["client_id"], name: "index_invoices_on_client_id"
    t.index ["invoice_number"], name: "index_invoices_on_invoice_number", unique: true
    t.index ["parent_invoice_id"], name: "index_invoices_on_parent_invoice_id"
    t.index ["project_id"], name: "index_invoices_on_project_id"
    t.index ["public_token"], name: "index_invoices_on_public_token", unique: true
    t.index ["status"], name: "index_invoices_on_status"
    t.index ["user_id"], name: "index_invoices_on_user_id"
  end

  create_table "payments", force: :cascade do |t|
    t.decimal "amount", precision: 12, scale: 2, default: "0.0", null: false
    t.date "payment_date", null: false
    t.integer "payment_method", default: 0, null: false
    t.string "reference"
    t.text "notes"
    t.string "stripe_payment_intent_id"
    t.bigint "invoice_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invoice_id"], name: "index_payments_on_invoice_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.decimal "hourly_rate", precision: 12, scale: 2, default: "0.0"
    t.decimal "budget", precision: 12, scale: 2, default: "0.0"
    t.integer "status", default: 0, null: false
    t.string "currency", default: "USD", null: false
    t.bigint "client_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_projects_on_client_id"
    t.index ["status"], name: "index_projects_on_status"
    t.index ["user_id"], name: "index_projects_on_user_id"
  end

  create_table "time_entries", force: :cascade do |t|
    t.string "description", null: false
    t.decimal "hours", precision: 8, scale: 2, default: "0.0", null: false
    t.date "date", null: false
    t.boolean "billable", default: true, null: false
    t.boolean "invoiced", default: false, null: false
    t.bigint "project_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["date"], name: "index_time_entries_on_date"
    t.index ["project_id"], name: "index_time_entries_on_project_id"
    t.index ["user_id"], name: "index_time_entries_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "name"
    t.string "business_name"
    t.text "business_address"
    t.string "tax_id"
    t.string "default_currency", default: "USD", null: false
    t.text "bank_details"
    t.string "invoice_prefix", default: "INV", null: false
    t.integer "invoice_counter", default: 0, null: false
    t.string "phone"
    t.string "website"
    t.string "stripe_account_id"
    t.string "payment_terms_days", default: "30"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "clients", "users"
  add_foreign_key "expenses", "projects"
  add_foreign_key "expenses", "users"
  add_foreign_key "invoice_items", "invoices"
  add_foreign_key "invoices", "clients"
  add_foreign_key "invoices", "invoices", column: "parent_invoice_id"
  add_foreign_key "invoices", "projects"
  add_foreign_key "invoices", "users"
  add_foreign_key "payments", "invoices"
  add_foreign_key "projects", "clients"
  add_foreign_key "projects", "users"
  add_foreign_key "time_entries", "projects"
  add_foreign_key "time_entries", "users"
end
