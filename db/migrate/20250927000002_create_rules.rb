# frozen_string_literal: true

class CreateRules < ActiveRecord::Migration[8.0]
  def change
    create_table :rules do |t|
      t.string :name, null: false
      t.text :description

      # Basic rule classification
      t.string :rule_type, null: false # risk_management, trading_behavior, payout_eligibility, account_lifecycle
      t.string :data_type, null: false # percentage, currency_amount, integer_count, boolean_flag, time_duration

      # Middle ground risk model extensions
      t.string :calculation_method, default: "simple_threshold", null: false
      # simple_threshold, daily_loss, total_drawdown, consistency_ratio, trading_days, position_size

      t.string :time_scope, default: "daily", null: false
      # per_trade, daily, lifetime, rolling_30

      t.string :violation_action, default: "hard_breach", null: false
      # hard_breach, soft_warning, payout_block

      # Flexible validation configuration
      t.jsonb :validation_config, default: {} # { max: 5.0, min: 10, reference: 'daily_start', min_trades: 10 }

      t.boolean :is_active, default: true, null: false
      t.integer :sort_order, default: 0

      t.timestamps
    end

    add_index :rules, :name, unique: true
    add_index :rules, :rule_type
    add_index :rules, :calculation_method
    add_index :rules, :time_scope
    add_index :rules, :violation_action
    add_index :rules, :is_active
    add_index :rules, :validation_config, using: :gin
  end
end
