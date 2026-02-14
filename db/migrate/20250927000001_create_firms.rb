# frozen_string_literal: true

class CreateFirms < ActiveRecord::Migration[8.0]
  def change
    create_table :firms do |t|
      t.string :name, null: false
      t.string :legal_name
      t.string :description
      t.string :website_url
      t.date :founding_date
      t.string :country_code, limit: 2
      t.string :status, default: "active", null: false
      t.text :contact_info # JSON: email, phone, address
      t.text :metadata # JSON: additional firm-specific data

      t.timestamps
    end

    add_index :firms, :name, unique: true
    add_index :firms, :status
    add_index :firms, :country_code
  end
end
