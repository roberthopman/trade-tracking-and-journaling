# frozen_string_literal: true

class EnhanceUsersTable < ActiveRecord::Migration[8.0]
  def change
    # Add optional UUID for secure URLs (keeping integer PK for performance)
    add_column :users, :uuid, :uuid, default: -> { "gen_random_uuid()" }, null: false
    add_index :users, :uuid, unique: true

    # Add Trackable fields (optional)
    add_column :users, :sign_in_count, :integer, default: 0, null: false
    add_column :users, :current_sign_in_at, :datetime
    add_column :users, :last_sign_in_at, :datetime
    add_column :users, :current_sign_in_ip, :string
    add_column :users, :last_sign_in_ip, :string

    # Add Confirmable fields (optional)
    add_column :users, :confirmation_token, :string
    add_column :users, :confirmed_at, :datetime
    add_column :users, :confirmation_sent_at, :datetime
    add_column :users, :unconfirmed_email, :string

    # Add User profile fields
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :timezone, :string, default: "UTC"
    add_column :users, :status, :string, default: "active", null: false # active, suspended, inactive
    add_column :users, :date_of_birth, :date
    add_column :users, :country_code, :string, limit: 2

    # Preferences
    add_column :users, :preferences, :jsonb, default: {} # UI preferences, notification settings, etc.

    # Add new indexes
    add_index :users, :confirmation_token, unique: true
    add_index :users, :status
    add_index :users, [:last_name, :first_name]
    add_index :users, :preferences, using: :gin
  end
end
