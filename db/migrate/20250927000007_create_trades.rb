# frozen_string_literal: true

class CreateTrades < ActiveRecord::Migration[8.0]
  def change
    create_table :trades do |t|
      add_basic_trade_columns(t)
      add_position_columns(t)
      add_risk_management_columns(t)
      add_analysis_columns(t)
      add_calculated_columns(t)
      t.timestamps
    end

    add_trades_indexes
  end

  private

  def add_basic_trade_columns(table)
    table.references :account, null: false, foreign_key: true
    table.uuid :uuid, default: -> { "gen_random_uuid()" }, null: false
    table.date :trade_date, null: false
    table.decimal :pnl, precision: 15, scale: 5, null: false
    table.string :symbol
    table.string :trade_type
    table.string :market
  end

  def add_position_columns(table)
    table.decimal :volume, precision: 15, scale: 5
    table.decimal :entry_price, precision: 15, scale: 8
    table.decimal :exit_price, precision: 15, scale: 8
    table.datetime :entry_time
    table.datetime :exit_time
  end

  def add_risk_management_columns(table)
    table.decimal :stop_loss, precision: 15, scale: 8
    table.decimal :take_profit, precision: 15, scale: 8
    table.decimal :commission, precision: 15, scale: 5, default: 0
    table.decimal :swap, precision: 15, scale: 5, default: 0
  end

  def add_analysis_columns(table)
    table.string :strategy
    table.text :setup
    table.string :emotional_state
    table.string :market_condition
    table.string :trade_grade
    table.text :tags
    table.text :notes
    table.text :lesson_learned
  end

  def add_calculated_columns(table)
    table.integer :duration_minutes
    table.decimal :risk_reward_ratio, precision: 10, scale: 3
    table.decimal :running_balance, precision: 15, scale: 2
    table.boolean :is_winning_trade
    table.string :external_trade_id
  end

  def add_trades_indexes
    add_index :trades, :uuid, unique: true
    add_index :trades, [:account_id, :trade_date]
    add_index :trades, :trade_date
    add_index :trades, :symbol
    add_index :trades, :strategy
    add_index :trades, :pnl
    add_index :trades, [:account_id, :pnl]
    add_index :trades, [:account_id, :is_winning_trade]
    add_index :trades, :external_trade_id, unique: true, where: "external_trade_id IS NOT NULL"
  end
end
