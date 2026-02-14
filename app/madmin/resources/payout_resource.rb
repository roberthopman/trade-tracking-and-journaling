# frozen_string_literal: true

class PayoutResource < Madmin::Resource
  # Attributes
  attribute :id, form: false

  # Index/Table Attributes (most important first)
  attribute :account, :belongs_to, index: true
  attribute :requested_date, index: true
  attribute :amount_requested, :number, index: true
  attribute :request_status, :select, collection: Payout::REQUEST_STATUSES, index: true
  attribute :payout_number, index: true
  attribute :notes, index: true

  # Additional attributes for forms and detail view
  attribute :amount_paid, :number
  attribute :received_date

  # Associations (space hidden - managed by ActsAsTenant)
  # Space attribute completely excluded since it's managed by ActsAsTenant
  attribute :created_at, form: false, index: false
  attribute :updated_at, form: false, index: false

  # Customize the display name of records in the admin area
  def self.display_name(record) = "Payout ##{record.payout_number} - #{record.account_identifier}"

  # Customize the default sort column and direction
  def self.default_sort_column = "requested_date"

  def self.default_sort_direction = "desc"
end
