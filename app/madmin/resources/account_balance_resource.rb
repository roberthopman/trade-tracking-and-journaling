# frozen_string_literal: true

class AccountBalanceResource < Madmin::Resource
  # Attributes
  attribute :id, form: false
  attribute :balance_date
  attribute :opening_balance
  attribute :closing_balance
  attribute :daily_pnl
  attribute :daily_high
  attribute :daily_low
  attribute :trade_count, form: false
  attribute :winning_trades
  attribute :losing_trades
  attribute :gross_profit
  attribute :gross_loss
  attribute :drawdown_from_high
  attribute :daily_return_percent
  attribute :created_at, form: false
  attribute :updated_at, form: false

  # Associations
  attribute :account

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
