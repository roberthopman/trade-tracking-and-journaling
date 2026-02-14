# frozen_string_literal: true

class RuleResource < Madmin::Resource
  # Attributes
  attribute :id, form: false
  # Required fields
  attribute :name
  attribute :rule_type, :select, collection: Rule::RULE_TYPES
  attribute :data_type, :select, collection: Rule::DATA_TYPES
  attribute :calculation_method, :select, collection: Rule::CALCULATION_METHODS
  attribute :time_scope, :select, collection: Rule::TIME_SCOPES
  attribute :violation_action, :select, collection: Rule::VIOLATION_ACTIONS
  attribute :validation_config
  # Optional fields
  attribute :description
  attribute :is_active
  attribute :sort_order
  attribute :created_at, form: false
  attribute :updated_at, form: false

  # Associations
  attribute :firm_rules
  attribute :firms
  attribute :account_rules
  attribute :accounts
  attribute :rule_violations

  # Add scopes to easily filter records
  # scope :published

  # Add actions to the resource's show page
  # member_action do |record|
  #   link_to "Do Something", some_path
  # end

  # Customize the display name of records in the admin area.
  def self.display_name(record) = record.to_s

  # Customize the default sort column and direction.
  # def self.default_sort_column = "created_at"
  #
  # def self.default_sort_direction = "desc"
end
