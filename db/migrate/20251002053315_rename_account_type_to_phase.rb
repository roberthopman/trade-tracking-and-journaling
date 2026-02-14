# frozen_string_literal: true

class RenameAccountTypeToPhase < ActiveRecord::Migration[8.0]
  def change
    rename_column :accounts, :account_type, :phase
  end
end
