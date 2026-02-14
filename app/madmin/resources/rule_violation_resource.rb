# frozen_string_literal: true

class RuleViolationResource < Madmin::Resource
  # Attributes
  attribute :id, form: false
  attribute :violation_type
  attribute :status
  attribute :severity
  attribute :threshold_value
  attribute :actual_value
  attribute :comparison_operator
  attribute :detected_at
  attribute :resolved_at
  attribute :violation_date
  attribute :details
  attribute :resolution_notes
  attribute :resolved_by
  attribute :action_taken
  attribute :account_terminated
  attribute :created_at, form: false
  attribute :updated_at, form: false

  # Associations
  attribute :account
  attribute :rule
  attribute :trade

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
