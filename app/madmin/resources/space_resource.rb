# frozen_string_literal: true

class SpaceResource < Madmin::Resource
  # Attributes
  attribute :id, form: false
  attribute :name
  attribute :description
  attribute :uuid
  attribute :status
  attribute :settings
  attribute :created_at, form: false
  attribute :updated_at, form: false

  # Associations
  attribute :space_memberships
  attribute :users
  attribute :firms
  attribute :accounts
  attribute :trades
  attribute :expenses
  attribute :rules
  attribute :tags

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
