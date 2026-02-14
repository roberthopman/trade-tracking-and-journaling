# frozen_string_literal: true

class AccountRuleResource < Madmin::Resource
  # Attributes
  attribute :id, form: false
  # Index/Table Attributes (most important first)
  attribute :account, index: true
  attribute :rule, index: true
  attribute :rule_value, index: true
  attribute :is_active, index: true
  attribute :start_date, index: true
  attribute :end_date, index: true

  # Additional attributes for forms and detail view
  attribute :is_inherited
  attribute :is_custom_override
  attribute :notes
  attribute :created_at, form: false
  attribute :updated_at, form: false

  # Associations (for completeness)
  attribute :account
  attribute :rule

  # Add scopes to easily filter records
  # scope :published

  # Add actions to the resource's show page
  # member_action do |record|
  #   link_to "Do Something", some_path
  # end

  # Customize the display name of records in the admin area.
  # def self.display_name(record) = record.name

  # Customize the default sort column and direction.
  # def self.default_sort_column = "created_at"
  #
  # def self.default_sort_direction = "desc"
end
