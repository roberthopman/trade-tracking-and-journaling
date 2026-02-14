# frozen_string_literal: true

class AddSpaceIdToAllTables < ActiveRecord::Migration[8.0]
  def up
    tables_to_update = [
      :firms,
      :accounts,
      :trades,
      :expenses,
      :rules,
      :tags,
      :account_rules,
      :account_balances,
      :firm_rules,
      :rule_violations,
      :trade_tags,
      :expense_tags
    ]

    tables_to_update.each do |table|
      # Skip if column already exists
      next if column_exists?(table, :space_id)

      add_column table, :space_id, :bigint
      add_index table, :space_id
      add_foreign_key table, :spaces
    end

    # Update unique indexes to include space_id scope
    unless index_exists?(:firms, [:space_id, :name], unique: true)
      remove_index :firms, :name if index_exists?(:firms, :name)
      add_index :firms, [:space_id, :name], unique: true
    end

    unless index_exists?(:rules, [:space_id, :name], unique: true)
      remove_index :rules, :name if index_exists?(:rules, :name)
      add_index :rules, [:space_id, :name], unique: true
    end
  end

  def down
    # Don't remove columns on rollback to prevent data loss
    # This is intentionally a no-op for safety
  end
end
