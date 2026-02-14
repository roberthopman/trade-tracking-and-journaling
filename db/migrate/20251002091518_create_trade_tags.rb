# frozen_string_literal: true

class CreateTradeTags < ActiveRecord::Migration[8.0]
  def change
    create_table :trade_tags do |t|
      t.references :trade, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true

      t.timestamps
    end

    add_index :trade_tags, [:trade_id, :tag_id], unique: true
  end
end
