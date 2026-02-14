# frozen_string_literal: true

class AddUniqueIndexToTagsNameAndSpaceId < ActiveRecord::Migration[8.0]
  def change
    add_index :tags, [:space_id, :name], unique: true
  end
end
