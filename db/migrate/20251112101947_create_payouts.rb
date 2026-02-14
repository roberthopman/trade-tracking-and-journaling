# frozen_string_literal: true

class CreatePayouts < ActiveRecord::Migration[8.0]
  def change
    create_table :payouts do |t|
      # Foreign Keys
      t.bigint :account_id, null: false
      t.bigint :space_id, null: false

      # Payout Request Info
      t.date :requested_date, null: false
      t.decimal :amount_requested, precision: 15, scale: 2, null: false
      t.string :request_status, null: false, default: "pending"

      # Payout Completion Info
      t.decimal :amount_paid, precision: 15, scale: 2
      t.date :received_date

      # Metadata
      t.integer :payout_number
      t.text :notes

      t.timestamps

      # Indexes
      t.index :account_id
      t.index :space_id
      t.index :request_status
      t.index :requested_date
      t.index [:account_id, :payout_number]
    end

    add_foreign_key :payouts, :accounts
    add_foreign_key :payouts, :spaces
  end
end
