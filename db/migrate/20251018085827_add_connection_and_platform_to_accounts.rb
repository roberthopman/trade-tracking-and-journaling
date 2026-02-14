# frozen_string_literal: true

class AddConnectionAndPlatformToAccounts < ActiveRecord::Migration[8.0]
  def change
    add_column :accounts, :connection, :string
    add_column :accounts, :platform, :string
  end
end
