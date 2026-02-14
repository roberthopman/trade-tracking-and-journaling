# frozen_string_literal: true

class CreateAccountBalances < ActiveRecord::Migration[8.0]
  def change
    create_table :account_balances do |t|
      t.references :account, null: false, foreign_key: true

      # Daily balance snapshot
      t.date :balance_date, null: false
      t.decimal :opening_balance, precision: 15, scale: 2, null: false
      t.decimal :closing_balance, precision: 15, scale: 2, null: false
      t.decimal :daily_pnl, precision: 15, scale: 5, null: false
      t.decimal :daily_high, precision: 15, scale: 2 # Highest intraday balance
      t.decimal :daily_low, precision: 15, scale: 2 # Lowest intraday balance

      # Daily statistics
      t.integer :trade_count, default: 0, null: false
      t.integer :winning_trades, default: 0, null: false
      t.integer :losing_trades, default: 0, null: false
      t.decimal :gross_profit, precision: 15, scale: 5, default: 0
      t.decimal :gross_loss, precision: 15, scale: 5, default: 0

      # Calculated metrics
      t.decimal :drawdown_from_high, precision: 15, scale: 5 # Drawdown from highest point
      t.decimal :daily_return_percent, precision: 10, scale: 5 # Daily return percentage

      t.timestamps
    end

    add_index :account_balances, [:account_id, :balance_date], unique: true
    add_index :account_balances, :balance_date
    add_index :account_balances, [:account_id, :daily_pnl]
    add_index :account_balances, [:account_id, :closing_balance]
  end
end
