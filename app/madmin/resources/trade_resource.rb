# frozen_string_literal: true

class TradeResource < Madmin::Resource
  # Index/Table Attributes (most important first)
  attribute :id, form: false
  attribute :trade_date, index: true
  attribute :symbol, index: true
  attribute :pnl, index: true
  attribute :trade_type, :select, collection: Trade::TRADE_TYPES, index: true
  attribute :volume, index: true, show: false
  attribute :account, index: true

  # Additional attributes for forms and detail view (hidden from show page)
  # Price information
  attribute :entry_price, show: false
  attribute :exit_price, show: false
  attribute :stop_loss, show: false
  attribute :take_profit, show: false
  # Timing
  attribute :entry_time, show: false
  attribute :exit_time, show: false
  attribute :duration_minutes, form: false, show: false
  # Performance metrics
  attribute :risk_reward_ratio, form: false, show: false
  attribute :commission, show: false
  attribute :swap, show: false
  attribute :running_balance, form: false, show: false
  attribute :is_winning_trade, form: false, show: false
  # Trading context
  attribute :strategy, show: false
  attribute :market, show: false
  attribute :setup, show: false
  attribute :emotional_state, show: false
  attribute :market_condition, show: false
  attribute :trade_grade, show: false
  # Additional info
  attribute :tags, show: false
  attribute :notes, show: false
  attribute :lesson_learned, show: false
  attribute :external_trade_id, show: false
  attribute :created_at, form: false, index: true
  attribute :updated_at, form: false

  # Add scopes to easily filter records
  # scope :published

  # Add actions to the resource's show page
  # member_action do |record|
  #   link_to "Do Something", some_path
  # end

  # Customize the display name of records in the admin area.
  def self.display_name(record) = record.to_s

  # Customize the default sort column and direction.
  def self.default_sort_column = "trade_date"

  def self.default_sort_direction = "desc"

  # Define which columns to show in index
  def self.table_attributes
    [:id, :trade_date, :symbol, :pnl, :trade_type, :volume, :account, :created_at]
  end

  # Customize column headers
  def self.human_attribute_name(attr, options = {})
    case attr.to_s
    when "volume"
      "Quantity"
    else
      super
    end
  end
end
