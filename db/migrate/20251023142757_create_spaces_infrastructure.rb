# frozen_string_literal: true

class CreateSpacesInfrastructure < ActiveRecord::Migration[8.0]
  def up
    # Skip if already exists
    return if table_exists?(:spaces)

    # Create spaces table
    create_table :spaces do |t|
      t.string :name, null: false
      t.text :description
      t.string :status, null: false, default: "active"
      t.jsonb :settings, default: {}
      t.uuid :uuid, null: false, default: -> { "gen_random_uuid()" }
      t.timestamps
    end

    add_index :spaces, :uuid, unique: true
    add_index :spaces, :status
    add_index :spaces, :name

    # Create space_memberships table
    create_table :space_memberships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :space, null: false, foreign_key: true
      t.string :role, null: false, default: "member"
      t.string :status, null: false, default: "active"
      t.timestamps
    end

    add_index :space_memberships, [:user_id, :space_id], unique: true
    add_index :space_memberships, [:space_id, :role]
    add_index :space_memberships, [:user_id, :status]
  end

  def down
    drop_table :space_memberships if table_exists?(:space_memberships)
    drop_table :spaces if table_exists?(:spaces)
  end
end
