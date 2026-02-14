# frozen_string_literal: true

class CreateRuleViolations < ActiveRecord::Migration[8.0]
  def change
    create_table :rule_violations do |t|
      t.references :account, null: false, foreign_key: true
      t.references :rule, null: false, foreign_key: true
      t.references :trade, null: true, foreign_key: true # If violation triggered by specific trade

      # Violation details
      t.string :violation_type, null: false # daily_loss, total_drawdown, consistency_ratio, etc.
      t.string :status, default: "active", null: false # active, resolved, ignored
      t.string :severity, null: false # warning, minor, major, critical

      # Values at time of violation
      t.decimal :threshold_value, precision: 15, scale: 5 # Rule threshold
      t.decimal :actual_value, precision: 15, scale: 5 # Actual value that violated
      t.string :comparison_operator # '>', '<', '=', etc.

      # Timing
      t.datetime :detected_at, null: false
      t.datetime :resolved_at
      t.date :violation_date # Business date when violation occurred

      # Context and resolution
      t.text :details # JSON with calculation details
      t.text :resolution_notes
      t.string :resolved_by # user_id who resolved it

      # Actions taken
      t.string :action_taken # hard_breach, soft_warning, payout_block
      t.boolean :account_terminated, default: false, null: false

      t.timestamps
    end

    add_index :rule_violations, [:account_id, :status]
    add_index :rule_violations, [:rule_id, :detected_at]
    add_index :rule_violations, :violation_date
    add_index :rule_violations, :severity
    add_index :rule_violations, [:account_id, :violation_date]
    add_index :rule_violations, :account_terminated
  end
end
