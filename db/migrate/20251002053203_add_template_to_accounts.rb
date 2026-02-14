# frozen_string_literal: true

class AddTemplateToAccounts < ActiveRecord::Migration[8.0]
  def change
    add_column :accounts, :template, :boolean, default: false, null: false
    add_index :accounts, :template
  end
end
