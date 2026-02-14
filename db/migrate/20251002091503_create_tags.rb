# frozen_string_literal: true

class CreateTags < ActiveRecord::Migration[8.0]
  def change
    create_table :tags do |t|
      t.string :name, null: false
      t.string :color, default: "#3B82F6"
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :tags, [:user_id, :name], unique: true
  end
end
