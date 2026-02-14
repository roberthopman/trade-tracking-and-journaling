# frozen_string_literal: true

class AccountResource < Madmin::Resource
  # Attributes
  attribute :id, form: false
  # Index/Table Attributes (most important first)
  attribute :firm, index: true
  attribute :name, index: true
  attribute :phase, :select, collection: Account::PHASES, index: true
  attribute :initial_balance, form: false, index: false
  attribute :status, :select, collection: Account::STATUSES, index: true
  attribute :user, form: false, show: false, index: false
  attribute :template, form: false, show: false, index: false, edit: false

  # Show page attributes (only these shown on detail page)
  attribute :external_id, show: true, index: false
  attribute :connection, show: true, index: false
  attribute :platform, show: true, index: false
  attribute :description, show: true, index: false
  attribute :currency, show: true, index: false
  attribute :start_date, show: true, index: false
  attribute :end_date, show: true, index: false

  # Add actions to the resource's show page
  # member_action do |record|
  #   link_to "Do Something", some_path
  # end

  # Customize the display name of records in the admin area.
  def self.display_name(record) = record.to_s

  # Custom formatters
  def initial_balance(record)
    number_to_currency(record.initial_balance, precision: 2)
  end

  # Customize the default sort column and direction.
  # def self.default_sort_column = "created_at"
  #
  # def self.default_sort_direction = "desc"
end
