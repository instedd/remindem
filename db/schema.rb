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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20160311184537) do

  create_table "channels", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "address"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",      :default => 0
    t.integer  "attempts",      :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "message_id",    :default => 0
    t.integer  "subscriber_id", :default => 0
    t.string   "queue"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "identities", :force => true do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "instedd_telemetry_counters", :force => true do |t|
    t.integer "period_id"
    t.string  "bucket"
    t.text    "key_attributes"
    t.integer "count",               :default => 0
    t.string  "key_attributes_hash"
  end

  add_index "instedd_telemetry_counters", ["bucket", "key_attributes_hash", "period_id"], :name => "instedd_telemetry_counters_unique_fields", :unique => true

  create_table "instedd_telemetry_periods", :force => true do |t|
    t.datetime "beginning"
    t.datetime "end"
    t.datetime "stats_sent_at"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.string   "lock_owner"
    t.datetime "lock_expiration"
  end

  create_table "instedd_telemetry_set_occurrences", :force => true do |t|
    t.integer "period_id"
    t.string  "bucket"
    t.text    "key_attributes"
    t.string  "element"
    t.string  "key_attributes_hash"
  end

  add_index "instedd_telemetry_set_occurrences", ["bucket", "key_attributes_hash", "element", "period_id"], :name => "instedd_telemetry_set_occurrences_unique_fields", :unique => true

  create_table "instedd_telemetry_settings", :force => true do |t|
    t.string "key"
    t.string "value"
  end

  add_index "instedd_telemetry_settings", ["key"], :name => "index_instedd_telemetry_settings_on_key", :unique => true

  create_table "instedd_telemetry_timespans", :force => true do |t|
    t.string   "bucket"
    t.text     "key_attributes"
    t.datetime "since"
    t.datetime "until"
    t.string   "key_attributes_hash"
  end

  add_index "instedd_telemetry_timespans", ["bucket", "key_attributes_hash"], :name => "instedd_telemetry_timespans_unique_fields", :unique => true

  create_table "logs", :force => true do |t|
    t.string   "severity"
    t.text     "description"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.integer  "schedule_id", :default => 0
  end

  create_table "messages", :force => true do |t|
    t.string   "text"
    t.integer  "offset"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "schedule_id"
    t.text     "occurrence_rule"
    t.text     "external_actions"
    t.string   "type"
  end

  add_index "messages", ["schedule_id"], :name => "fk_messages_schedules"

  create_table "schedules", :force => true do |t|
    t.string   "keyword"
    t.string   "timescale"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "welcome_message"
    t.string   "type"
    t.string   "title"
    t.boolean  "paused",          :default => false
  end

  add_index "schedules", ["user_id"], :name => "fk_schedules_users"

  create_table "subscribers", :force => true do |t|
    t.string   "phone_number"
    t.datetime "subscribed_at"
    t.integer  "offset"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "schedule_id"
  end

  add_index "subscribers", ["schedule_id"], :name => "fk_subscribers_schedules"

  create_table "users", :force => true do |t|
    t.string   "email",                                 :default => "", :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "lang",                   :limit => 10
    t.text     "features"
  end

  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
