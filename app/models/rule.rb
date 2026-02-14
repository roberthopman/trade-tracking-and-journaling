# frozen_string_literal: true

# == Schema Information
#
# Table name: rules
#
#  id                 :bigint           not null, primary key
#  calculation_method :string           default("simple_threshold"), not null
#  data_type          :string           not null
#  description        :text
#  is_active          :boolean          default(TRUE), not null
#  name               :string           not null
#  rule_type          :string           not null
#  sort_order         :integer          default(0)
#  time_scope         :string           default("daily"), not null
#  validation_config  :jsonb
#  violation_action   :string           default("hard_breach"), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  space_id           :bigint           not null
#
# Indexes
#
#  index_rules_on_calculation_method  (calculation_method)
#  index_rules_on_is_active           (is_active)
#  index_rules_on_rule_type           (rule_type)
#  index_rules_on_space_id            (space_id)
#  index_rules_on_space_id_and_name   (space_id,name) UNIQUE
#  index_rules_on_time_scope          (time_scope)
#  index_rules_on_validation_config   (validation_config) USING gin
#  index_rules_on_violation_action    (violation_action)
#
# Foreign Keys
#
#  fk_rails_...  (space_id => spaces.id)
#
class Rule < ApplicationRecord
  acts_as_tenant :space

  # Constants
  RULE_TYPES = %w[risk_management trading_behavior payout_eligibility account_lifecycle].freeze
  DATA_TYPES = %w[percentage currency_amount integer_count boolean_flag time_duration].freeze
  CALCULATION_METHODS = %w[
    simple_threshold
    daily_loss
    total_drawdown
    consistency_ratio
    trading_days
    position_size
    max_contracts
    trailing_drawdown
    drawdown_mode
  ].freeze
  TIME_SCOPES = %w[per_trade daily lifetime rolling_30].freeze
  VIOLATION_ACTIONS = %w[hard_breach soft_warning payout_block].freeze

  TRADING_RULES = [
    "Daily Loss Limit ($)",
    "Max Total Loss ($)",
    "Profit Target (%)",
    "Min Trading Days",
    "Min Trading Day Amount ($)",
    "Consistency Rule (%)",
    "Safety Net (%)",
    "Max Position Size (%)",
    "Leverage Limit",
    "Phase 1 Target (%)",
    "Safety Net ($)",
    "Profit Target ($)"
  ].freeze

  TRADING_RESTRICTIONS = [
    "Weekend Holding",
    "News Trading"
  ].freeze

  PAYOUT_RULES = [
    "Minimum Payout ($)",
    "Payout Frequency (days)",
    "Profit Split (%)",
    "First Payout Wait (days)",
    "Min Trading Days (Payout)"
  ].freeze

  PAYOUT_RESTRICTIONS = [
    "KYC Required"
  ].freeze

  # Associations
  belongs_to :space
  has_many :firm_rules, dependent: :destroy
  has_many :firms, through: :firm_rules
  has_many :account_rules, dependent: :destroy
  has_many :accounts, through: :account_rules
  has_many :rule_violations, dependent: :destroy

  # Validations
  validates :name, presence: true, uniqueness: {scope: :space_id}
  validates :rule_type, presence: true, inclusion: {in: RULE_TYPES}
  validates :data_type, presence: true, inclusion: {in: DATA_TYPES}
  validates :calculation_method, presence: true, inclusion: {in: CALCULATION_METHODS}
  validates :time_scope, presence: true, inclusion: {in: TIME_SCOPES}
  validates :violation_action, presence: true, inclusion: {in: VIOLATION_ACTIONS}
  validates :validation_config, presence: true

  # Scopes
  scope :active, -> { where(is_active: true) }
  scope :by_type, ->(type) { where(rule_type: type) }
  scope :by_calculation_method, ->(method) { where(calculation_method: method) }
  scope :risk_management, -> { where(rule_type: "risk_management") }
  scope :payout_eligibility, -> { where(rule_type: "payout_eligibility") }
  scope :trading_rules, -> { where(name: TRADING_RULES) }
  scope :trading_restrictions, -> { where(name: TRADING_RESTRICTIONS) }
  scope :payout_rules, -> { where(name: PAYOUT_RULES) }
  scope :payout_restrictions, -> { where(name: PAYOUT_RESTRICTIONS) }

  # Instance methods
  def threshold_value
    validation_config["max"] || validation_config["min"]
  end

  def minimum?
    validation_config.key?("min")
  end

  def maximum?
    validation_config.key?("max")
  end

  def to_s
    "##{id} - #{name}"
  end
end
