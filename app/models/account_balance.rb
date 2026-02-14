# frozen_string_literal: true

# == Schema Information
#
# Table name: account_balances
#
#  id                   :bigint           not null, primary key
#  balance_date         :date             not null
#  closing_balance      :decimal(15, 2)   not null
#  daily_high           :decimal(15, 2)
#  daily_low            :decimal(15, 2)
#  daily_pnl            :decimal(15, 5)   not null
#  daily_return_percent :decimal(10, 5)
#  drawdown_from_high   :decimal(15, 5)
#  gross_loss           :decimal(15, 5)   default(0.0)
#  gross_profit         :decimal(15, 5)   default(0.0)
#  losing_trades        :integer          default(0), not null
#  opening_balance      :decimal(15, 2)   not null
#  trade_count          :integer          default(0), not null
#  winning_trades       :integer          default(0), not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  account_id           :bigint           not null
#  space_id             :bigint           not null
#
# Indexes
#
#  index_account_balances_on_account_id                      (account_id)
#  index_account_balances_on_account_id_and_balance_date     (account_id,balance_date) UNIQUE
#  index_account_balances_on_account_id_and_closing_balance  (account_id,closing_balance)
#  index_account_balances_on_account_id_and_daily_pnl        (account_id,daily_pnl)
#  index_account_balances_on_balance_date                    (balance_date)
#  index_account_balances_on_space_id                        (space_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (space_id => spaces.id)
#
class AccountBalance < ApplicationRecord
  acts_as_tenant :space

  # Associations
  belongs_to :account

  # Callbacks
  before_validation :set_space_from_account

  # Validations
  validates :balance_date, presence: true, uniqueness: {scope: :account_id}
  validates :opening_balance, presence: true, numericality: true
  validates :closing_balance, presence: true, numericality: true
  validates :daily_pnl, presence: true, numericality: true
  validates :trade_count, presence: true, numericality: {greater_than_or_equal_to: 0}
  validate :closing_balance_calculation

  # Scopes
  scope :profitable_days, -> { where("daily_pnl > 0") }
  scope :losing_days, -> { where("daily_pnl < 0") }
  scope :break_even_days, -> { where(daily_pnl: 0) }
  scope :recent, ->(days = 30) { where(balance_date: days.days.ago..) }
  scope :ordered, -> { order(:balance_date) }

  # Instance methods
  def profitable_day?
    daily_pnl > 0
  end

  def losing_day?
    daily_pnl < 0
  end

  def break_even_day?
    daily_pnl.zero?
  end

  def win_rate
    return 0 if trade_count.zero?

    (winning_trades.to_f / trade_count * 100).round(2)
  end

  def average_trade_pnl
    return 0 if trade_count.zero?

    daily_pnl / trade_count
  end

  private

  def closing_balance_calculation
    calculated_closing = opening_balance + daily_pnl
    return if (closing_balance - calculated_closing).abs < 0.01

    errors.add(:closing_balance, "must equal opening balance plus daily P&L")
  end

  def set_space_from_account
    self.space ||= account&.space
  end
end
