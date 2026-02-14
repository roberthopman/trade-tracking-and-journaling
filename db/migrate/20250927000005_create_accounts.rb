# frozen_string_literal: true

class CreateAccounts < ActiveRecord::Migration[8.0]
  def change
    create_table :accounts do |t|
      t.references :user, null: false, foreign_key: true
      t.references :firm, null: false, foreign_key: true

      # Add UUID for secure account URLs
      t.uuid :uuid, default: -> { "gen_random_uuid()" }, null: false

      # Account identification
      t.string :external_id # Firm's account ID (e.g., "FTMO-123456")
      t.string :account_type, null: false # challenge, verification, funded, demo
      t.string :name # User-friendly account name
      t.text :description

      # Financial data
      t.decimal :initial_balance, precision: 15, scale: 2, null: false
      t.string :currency, limit: 3, default: "USD", null: false

      # Account lifecycle
      t.date :start_date, null: false
      t.date :end_date # null means active
      t.string :status, default: "active", null: false # active, suspended, terminated, completed

      # Challenge/verification specific
      t.integer :challenge_phase # 1, 2, 3 for multi-phase challenges
      t.integer :max_trading_days # null for unlimited
      t.date :challenge_deadline

      # Performance tracking
      t.decimal :profit_target, precision: 15, scale: 2 # Required profit for this phase
      t.decimal :current_balance, precision: 15, scale: 2 # Calculated field, updated by trades
      t.decimal :high_water_mark, precision: 15, scale: 2 # Highest balance achieved
      t.date :last_trade_date

      # Metadata
      t.jsonb :metadata, default: {} # Platform-specific data, trading conditions, etc.

      t.timestamps
    end

    add_index :accounts, :uuid, unique: true # For secure URL lookups
    add_index :accounts, [:user_id, :status]
    add_index :accounts, [:firm_id, :account_type]
    add_index :accounts, :external_id
    add_index :accounts, :status
    add_index :accounts, [:start_date, :end_date]
    add_index :accounts, :last_trade_date
    add_index :accounts, :metadata, using: :gin
  end
end
