# frozen_string_literal: true

class CreateExpenses < ActiveRecord::Migration[8.0]
  def change
    create_table :expenses do |t|
      t.string :title, null: false
      t.text :description
      t.decimal :amount, precision: 15, scale: 2, null: false
      t.date :expense_date, null: false
      t.string :recurrence_type, default: "one_time", null: false
      t.references :user, null: false, foreign_key: true
      t.uuid :uuid, null: false

      t.timestamps
    end

    add_index :expenses, :uuid, unique: true
    add_index :expenses, [:user_id, :expense_date]
    add_index :expenses, :recurrence_type
  end
end
