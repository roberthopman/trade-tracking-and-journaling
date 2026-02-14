# frozen_string_literal: true

class FirmResource < Madmin::Resource
  # Attributes
  attribute :id, form: false
  # Required fields
  attribute :name
  attribute :status, :select, collection: Firm::STATUSES
  # Optional fields
  attribute :legal_name, form: false, show: false
  attribute :description, form: false, show: false
  attribute :website_url, show: false
  attribute :founding_date, form: false, show: false
  attribute :contact_info, form: false, show: false
  attribute :created_at, :date, form: false, show: false

  # Associations
  attribute :account_types, form: false
  # attribute :firm_rules
  # attribute :rules
  # attribute :accounts
  # attribute :users

  # Add scopes to easily filter records
  # scope :published

  # Customize the display name of records in the admin area.
  def self.display_name(record) = record.to_s

  # Customize the default sort column and direction.
  def self.default_sort_column = "name"
  def self.default_sort_direction = "asc"
end
