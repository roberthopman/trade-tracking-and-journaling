# frozen_string_literal: true

class ExpenseResource < Madmin::Resource
  # Attributes
  attribute :id, form: false
  attribute :title, index: true
  attribute :amount, :number, form: false, index: true
  attribute :expense_date, index: true
  attribute :recurrence_type, :select, collection: Expense::RECURRENCE_TYPES, index: true
  attribute :tags, index: false
  attribute :description, form: false, index: false
  attribute :user, form: false, show: false, index: false
  attribute :uuid, form: false, show: false, index: false
  attribute :created_at, form: false, index: false
  attribute :updated_at, form: false, index: false

  def self.display_name(record) = record.to_s
end
