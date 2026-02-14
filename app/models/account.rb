# frozen_string_literal: true

# == Schema Information
#
# Table name: accounts
#
#  id                       :bigint           not null, primary key
#  auto_liquidity_threshold :decimal(15, 2)
#  challenge_deadline       :date
#  challenge_phase          :integer
#  connection               :string
#  currency                 :string(3)        default("USD"), not null
#  current_balance          :decimal(15, 2)
#  description              :text
#  end_date                 :date
#  high_water_mark          :decimal(15, 2)
#  initial_balance          :decimal(15, 2)   not null
#  last_trade_date          :date
#  max_trading_days         :integer
#  metadata                 :jsonb
#  name                     :string
#  peak_balance             :decimal(15, 2)
#  phase                    :string           not null
#  platform                 :string
#  profit_target            :decimal(15, 2)
#  start_date               :date
#  status                   :string           default("active"), not null
#  template                 :boolean          default(FALSE), not null
#  uuid                     :uuid             not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  external_id              :string
#  firm_id                  :bigint           not null
#  space_id                 :bigint           not null
#  user_id                  :bigint
#
# Indexes
#
#  index_accounts_on_firm_id                          (firm_id)
#  index_accounts_on_firm_id_and_phase                (firm_id,phase)
#  index_accounts_on_last_trade_date                  (last_trade_date)
#  index_accounts_on_metadata                         (metadata) USING gin
#  index_accounts_on_space_id                         (space_id)
#  index_accounts_on_space_id_and_external_id_unique  (space_id,external_id) UNIQUE WHERE (external_id IS NOT NULL)
#  index_accounts_on_start_date_and_end_date          (start_date,end_date)
#  index_accounts_on_status                           (status)
#  index_accounts_on_template                         (template)
#  index_accounts_on_user_id                          (user_id)
#  index_accounts_on_user_id_and_status               (user_id,status)
#  index_accounts_on_uuid                             (uuid) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (firm_id => firms.id)
#  fk_rails_...  (space_id => spaces.id)
#  fk_rails_...  (user_id => users.id)
#
class Account < ApplicationRecord
  include Account::PayoutCalculations
  include Account::RuleCalculations

  acts_as_tenant :space

  # Constants
  PHASES = %w[evaluation sim-funded live straight-to-funded-s2f].freeze
  STATUSES = %w[active suspended terminated completed].freeze

  # Phase display names
  PHASE_DISPLAY_NAMES = {
    "evaluation" => "Evaluation",
    "sim-funded" => "Sim-Funded",
    "live" => "Live",
    "straight-to-funded-s2f" => "Straight To Funded (S2F)"
  }.freeze

  # Callbacks
  before_validation :ensure_uuid
  before_validation :set_template_defaults, if: :template?
  after_create :inherit_rules_from_template, unless: :template?
  after_create :initialize_peak_balance, unless: :template?

  # Associations
  belongs_to :space
  belongs_to :user, optional: true
  belongs_to :firm
  has_many :account_rules, dependent: :destroy
  has_many :rules, through: :account_rules
  has_many :trades, dependent: :destroy
  has_many :rule_violations, dependent: :destroy
  has_many :account_balances, dependent: :destroy
  has_many :payouts, dependent: :destroy

  # Nested attributes
  accepts_nested_attributes_for :account_rules, reject_if: :reject_empty_rule_value

  # Validations
  validates :phase, presence: true, inclusion: {in: PHASES}
  validates :initial_balance, presence: true, numericality: {greater_than: 0}
  validates :currency, presence: true, length: {is: 3}
  validates :status, presence: true, inclusion: {in: STATUSES}
  validates :start_date, presence: true, unless: :template?
  validates :user, presence: true, unless: :template?
  validates :uuid, uniqueness: true
  validates :external_id, presence: true, unless: :template?
  validates :external_id, uniqueness: {scope: :space_id, message: "already exists"}, allow_blank: true
  validate :end_date_after_start_date

  # Scopes
  scope :active, -> { where(status: "active") }
  scope :templates, -> { where(template: true) }
  scope :real_accounts, -> { where(template: false) }
  scope :by_phase, ->(phase) { where(phase: phase) }
  scope :by_firm, ->(firm) { where(firm: firm) }
  scope :funded, -> { where(phase: "funded") }
  scope :challenges, -> { where(phase: "challenge") }

  # Instance methods
  def current_balance
    # Reset balance to initial for suspended/terminated accounts (blown accounts)
    return initial_balance.to_i if status.in?(%w[suspended terminated])

    initial_balance.to_i + trades_sum_pnl - total_payouts_paid
  end

  def trades_sum_pnl
    # No P&L for suspended/terminated accounts
    return 0 if status.in?(%w[suspended terminated])

    trades.any? ? trades.sum(:pnl) : 0
  end

  def total_payouts_paid
    # No payouts counted for suspended/terminated accounts
    return 0 if status.in?(%w[suspended terminated])

    payouts.approved.where.not(amount_paid: nil).sum(:amount_paid)
  end

  def balance_at_start_of_day(date)
    trades_before_date = trades.where(trade_date: ...date)
    initial_balance + trades_before_date.sum(:pnl)
  end

  def current_rules(date = Date.current)
    account_rules.active.current(date).includes(:rule)
  end

  def profit_loss
    # No profit/loss for suspended/terminated accounts
    return 0 if status.in?(%w[suspended terminated])

    current_balance - initial_balance
  end

  def profit_loss_percentage
    return 0 if initial_balance.zero?
    # No profit/loss percentage for suspended/terminated accounts
    return 0 if status.in?(%w[suspended terminated])

    (profit_loss / initial_balance) * 100
  end

  def available_drawdown
    return nil if auto_liquidity_threshold.blank?
    # Available drawdown is 0 for suspended/terminated accounts
    return 0 if status.in?(%w[suspended terminated])

    current_balance - auto_liquidity_threshold
  end

  def trading_days_count(period = 30.days)
    start_date = period.ago.to_date
    trades.where(trade_date: start_date..).distinct.count(:trade_date)
  end

  def total_trading_days
    trades.distinct.count(:trade_date)
  end

  def qualified_trading_days
    min_amount = min_trading_day_amount_rule_value
    return total_trading_days if min_amount.nil? || min_amount.zero?

    trades
      .group(:trade_date)
      .having("ABS(SUM(pnl)) >= ?", min_amount)
      .count
      .size
  end

  def non_qualified_trading_days
    total_trading_days - qualified_trading_days
  end

  def daily_trading_volumes
    trades
      .group(:trade_date)
      .select(
        "trade_date",
        "SUM(pnl) as volume",
        "COUNT(*) as trade_count"
      )
      .order(trade_date: :desc)
      .map do |day|
        {
          date: day.trade_date,
          volume: day.volume.to_f,
          trade_count: day.trade_count,
          qualified: day.volume.to_f >= min_trading_day_amount_threshold
        }
      end
  end

  def winning_trades_count
    trades.where("pnl > 0").count
  end

  def losing_trades_count
    trades.where("pnl < 0").count
  end

  def best_trading_day
    trades.group(:trade_date).sum(:pnl).values.max || 0
  end

  def biggest_day
    best_trading_day
  end

  def phase_display_name
    PHASE_DISPLAY_NAMES[phase] || phase.titleize
  end

  def peak_balance
    # If we have a stored peak_balance, use it
    stored_peak = read_attribute(:peak_balance)
    return stored_peak if stored_peak.present?

    # Otherwise, calculate the true peak by finding the highest balance achieved
    calculate_peak_balance
  end

  def calculate_peak_balance
    return initial_balance if trades.empty?

    # Calculate running balance and find the peak
    running_balance = initial_balance
    peak = initial_balance

    trades.order(:trade_date, :id).each do |trade|
      running_balance += trade.pnl
      peak = running_balance if running_balance > peak
    end

    peak
  end

  def to_s
    return name.to_s if external_id.blank?

    "#{name} (#{external_id})"
  end

  private

  def ensure_uuid
    self.uuid ||= SecureRandom.uuid
  end

  def set_template_defaults
    self.currency = "USD"
    self.status = "active"
    if initial_balance.present?
      self.name ||= "#{phase.titleize} - #{ActionController::Base.helpers.number_to_human(
        initial_balance,
        precision: 0,
        units: {thousand: "K", million: "M"}
      )}"
    end
  end

  def end_date_after_start_date
    return unless end_date.present? && start_date.present?

    errors.add(:end_date, "must be after start date") if end_date <= start_date
  end

  def reject_empty_rule_value(attributes)
    # Don't reject if updating existing record (has id)
    return false if attributes["id"].present?

    # Only reject new records with blank values
    attributes["rule_value"].blank?
  end

  def inherit_rules_from_template
    return if firm.blank?

    template = firm.accounts.templates.by_phase(phase).first
    return if template.blank?

    template.account_rules.each do |template_rule|
      account_rules.create!(
        rule_id: template_rule.rule_id,
        rule_value: template_rule.rule_value,
        start_date: start_date || Date.current,
        is_inherited: true,
        is_active: template_rule.is_active
      )
    end
  end

  def initialize_peak_balance
    update_column(:peak_balance, initial_balance) if peak_balance.nil?
  end
end
