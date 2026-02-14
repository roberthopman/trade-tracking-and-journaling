# frozen_string_literal: true

class CreateAccountRules < ActiveRecord::Migration[8.0]
  def change
    create_table :account_rules do |t|
      t.references :account, null: false, foreign_key: true
      t.references :rule, null: false, foreign_key: true

      # Rule value (can override firm default)
      t.string :rule_value, null: false
      t.date :start_date, null: false
      t.date :end_date # null means active indefinitely

      # Override settings
      t.boolean :is_inherited, default: true, null: false # true if inherited from firm
      t.boolean :is_custom_override, default: false, null: false # true if account-specific override

      # Status
      t.boolean :is_active, default: true, null: false
      t.text :notes # Account-specific notes about this rule

      t.timestamps
    end

    add_index :account_rules, [:account_id, :rule_id, :start_date], name: "idx_account_rules_unique_period"
    add_index :account_rules, [:account_id, :is_active]
    add_index :account_rules, [:rule_id, :start_date]
    add_index :account_rules, :is_inherited
    add_index :account_rules, :is_custom_override

    # Ensure no overlapping active periods for same account/rule combination
    add_index :account_rules,
      [:account_id, :rule_id],
      where: "end_date IS NULL",
      unique: true,
      name: "idx_account_rules_no_overlap_active"
  end
end
