# frozen_string_literal: true

class AddUniqueIndexToAccountsExternalId < ActiveRecord::Migration[8.0]
  def change
    remove_index :accounts, :external_id, if_exists: true
    add_index :accounts,
      [:space_id, :external_id],
      unique: true,
      where: "external_id IS NOT NULL",
      name: "index_accounts_on_space_id_and_external_id_unique"
  end
end
