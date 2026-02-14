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

ActiveRecord::Schema[8.0].define(version: 2025_11_25_131822) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_stat_statements"

  create_table "account_balances", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.date "balance_date", null: false
    t.decimal "opening_balance", precision: 15, scale: 2, null: false
    t.decimal "closing_balance", precision: 15, scale: 2, null: false
    t.decimal "daily_pnl", precision: 15, scale: 5, null: false
    t.decimal "daily_high", precision: 15, scale: 2
    t.decimal "daily_low", precision: 15, scale: 2
    t.integer "trade_count", default: 0, null: false
    t.integer "winning_trades", default: 0, null: false
    t.integer "losing_trades", default: 0, null: false
    t.decimal "gross_profit", precision: 15, scale: 5, default: "0.0"
    t.decimal "gross_loss", precision: 15, scale: 5, default: "0.0"
    t.decimal "drawdown_from_high", precision: 15, scale: 5
    t.decimal "daily_return_percent", precision: 10, scale: 5
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "space_id"
    t.index ["account_id", "balance_date"], name: "index_account_balances_on_account_id_and_balance_date", unique: true
    t.index ["account_id", "closing_balance"], name: "index_account_balances_on_account_id_and_closing_balance"
    t.index ["account_id", "daily_pnl"], name: "index_account_balances_on_account_id_and_daily_pnl"
    t.index ["account_id"], name: "index_account_balances_on_account_id"
    t.index ["balance_date"], name: "index_account_balances_on_balance_date"
    t.index ["space_id"], name: "index_account_balances_on_space_id"
    t.check_constraint "closing_balance = (opening_balance + daily_pnl)", name: "balance_calculation_integrity"
  end

  create_table "account_rules", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "rule_id", null: false
    t.string "rule_value", null: false
    t.date "start_date", null: false
    t.date "end_date"
    t.boolean "is_inherited", default: true, null: false
    t.boolean "is_custom_override", default: false, null: false
    t.boolean "is_active", default: true, null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "space_id"
    t.index ["account_id", "is_active"], name: "index_account_rules_on_account_id_and_is_active"
    t.index ["account_id", "rule_id", "start_date"], name: "idx_account_rules_unique_period"
    t.index ["account_id", "rule_id"], name: "idx_account_rules_no_overlap_active", unique: true, where: "(end_date IS NULL)"
    t.index ["account_id"], name: "index_account_rules_on_account_id"
    t.index ["is_custom_override"], name: "index_account_rules_on_is_custom_override"
    t.index ["is_inherited"], name: "index_account_rules_on_is_inherited"
    t.index ["rule_id", "start_date"], name: "index_account_rules_on_rule_id_and_start_date"
    t.index ["rule_id"], name: "index_account_rules_on_rule_id"
    t.index ["space_id"], name: "index_account_rules_on_space_id"
    t.check_constraint "end_date IS NULL OR start_date < end_date", name: "valid_account_rule_date_range"
  end

  create_table "accounts", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "firm_id", null: false
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.string "external_id"
    t.string "phase", null: false
    t.string "name"
    t.text "description"
    t.decimal "initial_balance", precision: 15, scale: 2, null: false
    t.string "currency", limit: 3, default: "USD", null: false
    t.date "start_date"
    t.date "end_date"
    t.string "status", default: "active", null: false
    t.integer "challenge_phase"
    t.integer "max_trading_days"
    t.date "challenge_deadline"
    t.decimal "profit_target", precision: 15, scale: 2
    t.decimal "current_balance", precision: 15, scale: 2
    t.decimal "high_water_mark", precision: 15, scale: 2
    t.date "last_trade_date"
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "template", default: false, null: false
    t.string "connection"
    t.string "platform"
    t.bigint "space_id"
    t.decimal "peak_balance", precision: 15, scale: 2
    t.decimal "auto_liquidity_threshold", precision: 15, scale: 2
    t.index ["firm_id", "phase"], name: "index_accounts_on_firm_id_and_phase"
    t.index ["firm_id"], name: "index_accounts_on_firm_id"
    t.index ["last_trade_date"], name: "index_accounts_on_last_trade_date"
    t.index ["metadata"], name: "index_accounts_on_metadata", using: :gin
    t.index ["space_id", "external_id"], name: "index_accounts_on_space_id_and_external_id_unique", unique: true, where: "(external_id IS NOT NULL)"
    t.index ["space_id"], name: "index_accounts_on_space_id"
    t.index ["start_date", "end_date"], name: "index_accounts_on_start_date_and_end_date"
    t.index ["status"], name: "index_accounts_on_status"
    t.index ["template"], name: "index_accounts_on_template"
    t.index ["user_id", "status"], name: "index_accounts_on_user_id_and_status"
    t.index ["user_id"], name: "index_accounts_on_user_id"
    t.index ["uuid"], name: "index_accounts_on_uuid", unique: true
    t.check_constraint "end_date IS NULL OR start_date < end_date", name: "valid_account_date_range"
    t.check_constraint "initial_balance > 0::numeric", name: "positive_initial_balance"
  end

  create_table "expense_tags", force: :cascade do |t|
    t.bigint "expense_id", null: false
    t.bigint "tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "space_id"
    t.index ["expense_id", "tag_id"], name: "index_expense_tags_on_expense_id_and_tag_id", unique: true
    t.index ["expense_id"], name: "index_expense_tags_on_expense_id"
    t.index ["space_id"], name: "index_expense_tags_on_space_id"
    t.index ["tag_id"], name: "index_expense_tags_on_tag_id"
  end

  create_table "expenses", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.decimal "amount", precision: 15, scale: 2, null: false
    t.date "expense_date", null: false
    t.string "recurrence_type", default: "one_time", null: false
    t.bigint "user_id", null: false
    t.uuid "uuid", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "space_id"
    t.index ["recurrence_type"], name: "index_expenses_on_recurrence_type"
    t.index ["space_id"], name: "index_expenses_on_space_id"
    t.index ["user_id", "expense_date"], name: "index_expenses_on_user_id_and_expense_date"
    t.index ["user_id"], name: "index_expenses_on_user_id"
    t.index ["uuid"], name: "index_expenses_on_uuid", unique: true
  end

  create_table "firm_rules", force: :cascade do |t|
    t.bigint "firm_id", null: false
    t.bigint "rule_id", null: false
    t.string "rule_value", null: false
    t.date "start_date", null: false
    t.date "end_date"
    t.boolean "is_active", default: true, null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "space_id"
    t.index ["end_date"], name: "index_firm_rules_on_end_date"
    t.index ["firm_id", "is_active"], name: "index_firm_rules_on_firm_id_and_is_active"
    t.index ["firm_id", "rule_id", "start_date"], name: "idx_firm_rules_unique_period"
    t.index ["firm_id", "rule_id"], name: "idx_firm_rules_no_overlap_active", unique: true, where: "(end_date IS NULL)"
    t.index ["firm_id"], name: "index_firm_rules_on_firm_id"
    t.index ["rule_id", "start_date"], name: "index_firm_rules_on_rule_id_and_start_date"
    t.index ["rule_id"], name: "index_firm_rules_on_rule_id"
    t.index ["space_id"], name: "index_firm_rules_on_space_id"
    t.check_constraint "end_date IS NULL OR start_date < end_date", name: "valid_firm_rule_date_range"
  end

  create_table "firms", force: :cascade do |t|
    t.string "name", null: false
    t.string "legal_name"
    t.string "description"
    t.string "website_url"
    t.date "founding_date"
    t.string "country_code", limit: 2
    t.string "status", default: "active", null: false
    t.text "contact_info"
    t.text "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "space_id"
    t.index ["country_code"], name: "index_firms_on_country_code"
    t.index ["space_id", "name"], name: "index_firms_on_space_id_and_name", unique: true
    t.index ["space_id"], name: "index_firms_on_space_id"
    t.index ["status"], name: "index_firms_on_status"
  end

  create_table "payouts", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "space_id", null: false
    t.date "requested_date", null: false
    t.decimal "amount_requested", precision: 15, scale: 2, null: false
    t.string "request_status", default: "pending", null: false
    t.decimal "amount_paid", precision: 15, scale: 2
    t.date "received_date"
    t.integer "payout_number"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "payout_number"], name: "index_payouts_on_account_id_and_payout_number"
    t.index ["account_id"], name: "index_payouts_on_account_id"
    t.index ["request_status"], name: "index_payouts_on_request_status"
    t.index ["requested_date"], name: "index_payouts_on_requested_date"
    t.index ["space_id"], name: "index_payouts_on_space_id"
  end

  create_table "rule_violations", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "rule_id", null: false
    t.bigint "trade_id"
    t.string "violation_type", null: false
    t.string "status", default: "active", null: false
    t.string "severity", null: false
    t.decimal "threshold_value", precision: 15, scale: 5
    t.decimal "actual_value", precision: 15, scale: 5
    t.string "comparison_operator"
    t.datetime "detected_at", null: false
    t.datetime "resolved_at"
    t.date "violation_date"
    t.text "details"
    t.text "resolution_notes"
    t.string "resolved_by"
    t.string "action_taken"
    t.boolean "account_terminated", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "space_id"
    t.index ["account_id", "status"], name: "index_rule_violations_on_account_id_and_status"
    t.index ["account_id", "violation_date"], name: "index_rule_violations_on_account_id_and_violation_date"
    t.index ["account_id"], name: "index_rule_violations_on_account_id"
    t.index ["account_terminated"], name: "index_rule_violations_on_account_terminated"
    t.index ["rule_id", "detected_at"], name: "index_rule_violations_on_rule_id_and_detected_at"
    t.index ["rule_id"], name: "index_rule_violations_on_rule_id"
    t.index ["severity"], name: "index_rule_violations_on_severity"
    t.index ["space_id"], name: "index_rule_violations_on_space_id"
    t.index ["trade_id"], name: "index_rule_violations_on_trade_id"
    t.index ["violation_date"], name: "index_rule_violations_on_violation_date"
    t.check_constraint "resolved_at IS NULL OR detected_at <= resolved_at", name: "valid_violation_resolution_time"
  end

  create_table "rules", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.string "rule_type", null: false
    t.string "data_type", null: false
    t.string "calculation_method", default: "simple_threshold", null: false
    t.string "time_scope", default: "daily", null: false
    t.string "violation_action", default: "hard_breach", null: false
    t.jsonb "validation_config", default: {}
    t.boolean "is_active", default: true, null: false
    t.integer "sort_order", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "space_id"
    t.index ["calculation_method"], name: "index_rules_on_calculation_method"
    t.index ["is_active"], name: "index_rules_on_is_active"
    t.index ["rule_type"], name: "index_rules_on_rule_type"
    t.index ["space_id", "name"], name: "index_rules_on_space_id_and_name", unique: true
    t.index ["space_id"], name: "index_rules_on_space_id"
    t.index ["time_scope"], name: "index_rules_on_time_scope"
    t.index ["validation_config"], name: "index_rules_on_validation_config", using: :gin
    t.index ["violation_action"], name: "index_rules_on_violation_action"
  end

  create_table "space_memberships", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "space_id", null: false
    t.string "role", default: "member", null: false
    t.string "status", default: "active", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["space_id", "role"], name: "index_space_memberships_on_space_id_and_role"
    t.index ["space_id"], name: "index_space_memberships_on_space_id"
    t.index ["user_id", "space_id"], name: "index_space_memberships_on_user_id_and_space_id", unique: true
    t.index ["user_id", "status"], name: "index_space_memberships_on_user_id_and_status"
    t.index ["user_id"], name: "index_space_memberships_on_user_id"
  end

  create_table "spaces", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.string "status", default: "active", null: false
    t.jsonb "settings", default: {}
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_spaces_on_name"
    t.index ["status"], name: "index_spaces_on_status"
    t.index ["uuid"], name: "index_spaces_on_uuid", unique: true
  end

  create_table "tags", force: :cascade do |t|
    t.string "name", null: false
    t.string "color", default: "#3B82F6"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "space_id"
    t.index ["space_id", "name"], name: "index_tags_on_space_id_and_name", unique: true
    t.index ["space_id"], name: "index_tags_on_space_id"
    t.index ["user_id", "name"], name: "index_tags_on_user_id_and_name", unique: true
    t.index ["user_id"], name: "index_tags_on_user_id"
  end

  create_table "trade_tags", force: :cascade do |t|
    t.bigint "trade_id", null: false
    t.bigint "tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "space_id"
    t.index ["space_id"], name: "index_trade_tags_on_space_id"
    t.index ["tag_id"], name: "index_trade_tags_on_tag_id"
    t.index ["trade_id", "tag_id"], name: "index_trade_tags_on_trade_id_and_tag_id", unique: true
    t.index ["trade_id"], name: "index_trade_tags_on_trade_id"
  end

  create_table "trades", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.date "trade_date", null: false
    t.decimal "pnl", precision: 15, scale: 5, null: false
    t.string "symbol"
    t.string "trade_type"
    t.string "market"
    t.decimal "volume", precision: 15, scale: 5
    t.decimal "entry_price", precision: 15, scale: 8
    t.decimal "exit_price", precision: 15, scale: 8
    t.datetime "entry_time"
    t.datetime "exit_time"
    t.decimal "stop_loss", precision: 15, scale: 8
    t.decimal "take_profit", precision: 15, scale: 8
    t.decimal "commission", precision: 15, scale: 5, default: "0.0"
    t.decimal "swap", precision: 15, scale: 5, default: "0.0"
    t.string "strategy"
    t.text "setup"
    t.string "emotional_state"
    t.string "market_condition"
    t.string "trade_grade"
    t.text "tags"
    t.text "notes"
    t.text "lesson_learned"
    t.integer "duration_minutes"
    t.decimal "risk_reward_ratio", precision: 10, scale: 3
    t.decimal "running_balance", precision: 15, scale: 2
    t.boolean "is_winning_trade"
    t.string "external_trade_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "space_id"
    t.index ["account_id", "is_winning_trade"], name: "index_trades_on_account_id_and_is_winning_trade"
    t.index ["account_id", "pnl"], name: "index_trades_on_account_id_and_pnl"
    t.index ["account_id", "trade_date"], name: "index_trades_on_account_id_and_trade_date"
    t.index ["account_id"], name: "index_trades_on_account_id"
    t.index ["external_trade_id"], name: "index_trades_on_external_trade_id", unique: true, where: "(external_trade_id IS NOT NULL)"
    t.index ["pnl"], name: "index_trades_on_pnl"
    t.index ["space_id"], name: "index_trades_on_space_id"
    t.index ["strategy"], name: "index_trades_on_strategy"
    t.index ["symbol"], name: "index_trades_on_symbol"
    t.index ["trade_date"], name: "index_trades_on_trade_date"
    t.index ["uuid"], name: "index_trades_on_uuid", unique: true
    t.check_constraint "exit_time IS NULL OR entry_time IS NULL OR entry_time <= exit_time", name: "valid_trade_time_sequence"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "first_name"
    t.string "last_name"
    t.string "timezone", default: "UTC"
    t.string "status", default: "active", null: false
    t.date "date_of_birth"
    t.string "country_code", limit: 2
    t.jsonb "preferences", default: {}
    t.boolean "admin", default: false, null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["last_name", "first_name"], name: "index_users_on_last_name_and_first_name"
    t.index ["preferences"], name: "index_users_on_preferences", using: :gin
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["status"], name: "index_users_on_status"
    t.index ["uuid"], name: "index_users_on_uuid", unique: true
  end

  add_foreign_key "account_balances", "accounts"
  add_foreign_key "account_balances", "spaces"
  add_foreign_key "account_rules", "accounts"
  add_foreign_key "account_rules", "rules"
  add_foreign_key "account_rules", "spaces"
  add_foreign_key "accounts", "firms"
  add_foreign_key "accounts", "spaces"
  add_foreign_key "accounts", "users"
  add_foreign_key "expense_tags", "expenses"
  add_foreign_key "expense_tags", "spaces"
  add_foreign_key "expense_tags", "tags"
  add_foreign_key "expenses", "spaces"
  add_foreign_key "expenses", "users"
  add_foreign_key "firm_rules", "firms"
  add_foreign_key "firm_rules", "rules"
  add_foreign_key "firm_rules", "spaces"
  add_foreign_key "firms", "spaces"
  add_foreign_key "payouts", "accounts"
  add_foreign_key "payouts", "spaces"
  add_foreign_key "rule_violations", "accounts"
  add_foreign_key "rule_violations", "rules"
  add_foreign_key "rule_violations", "spaces"
  add_foreign_key "rule_violations", "trades"
  add_foreign_key "rules", "spaces"
  add_foreign_key "space_memberships", "spaces"
  add_foreign_key "space_memberships", "users"
  add_foreign_key "tags", "spaces"
  add_foreign_key "tags", "users"
  add_foreign_key "trade_tags", "spaces"
  add_foreign_key "trade_tags", "tags"
  add_foreign_key "trade_tags", "trades"
  add_foreign_key "trades", "accounts"
  add_foreign_key "trades", "spaces"
end
