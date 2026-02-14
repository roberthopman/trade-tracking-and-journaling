# frozen_string_literal: true

class AddAutoLiquidityFieldsToAccounts < ActiveRecord::Migration[8.0]
  def change
    add_column :accounts, :peak_balance, :decimal, precision: 15, scale: 2
    add_column :accounts, :auto_liquidity_threshold, :decimal, precision: 15, scale: 2
  end
end
