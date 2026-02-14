# frozen_string_literal: true

class CreateFirmRules < ActiveRecord::Migration[8.0]
  def change
    create_table :firm_rules do |t|
      t.references :firm, null: false, foreign_key: true
      t.references :rule, null: false, foreign_key: true

      t.string :rule_value, null: false # The specific value for this firm (e.g., "5.0" for 5%)
      t.date :start_date, null: false
      t.date :end_date # null means active indefinitely

      t.boolean :is_active, default: true, null: false
      t.text :notes # Firm-specific notes about this rule

      t.timestamps
    end

    add_index :firm_rules, [:firm_id, :rule_id, :start_date], name: "idx_firm_rules_unique_period"
    add_index :firm_rules, [:firm_id, :is_active]
    add_index :firm_rules, [:rule_id, :start_date]
    add_index :firm_rules, :end_date

    # Ensure no overlapping active periods for same firm/rule combination
    add_index :firm_rules,
      [:firm_id, :rule_id],
      where: "end_date IS NULL",
      unique: true,
      name: "idx_firm_rules_no_overlap_active"
  end
end
