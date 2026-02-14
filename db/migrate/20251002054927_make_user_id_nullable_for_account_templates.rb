# frozen_string_literal: true

class MakeUserIdNullableForAccountTemplates < ActiveRecord::Migration[8.0]
  def change
    change_column_null :accounts, :user_id, true
    change_column_null :accounts, :start_date, true
  end
end
