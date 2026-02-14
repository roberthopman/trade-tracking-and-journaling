# frozen_string_literal: true

class CreateExpenseTags < ActiveRecord::Migration[8.0]
  def change
    create_table :expense_tags do |t|
      t.references :expense, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true

      t.timestamps
    end

    add_index :expense_tags, [:expense_id, :tag_id], unique: true
  end
end
