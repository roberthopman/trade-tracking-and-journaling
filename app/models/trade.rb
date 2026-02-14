# frozen_string_literal: true

# == Schema Information
#
# Table name: trades
#
#  id                :bigint           not null, primary key
#  commission        :decimal(15, 5)   default(0.0)
#  duration_minutes  :integer
#  emotional_state   :string
#  entry_price       :decimal(15, 8)
#  entry_time        :datetime
#  exit_price        :decimal(15, 8)
#  exit_time         :datetime
#  is_winning_trade  :boolean
#  lesson_learned    :text
#  market            :string
#  market_condition  :string
#  notes             :text
#  pnl               :decimal(15, 5)   not null
#  risk_reward_ratio :decimal(10, 3)
#  running_balance   :decimal(15, 2)
#  setup             :text
#  stop_loss         :decimal(15, 8)
#  strategy          :string
#  swap              :decimal(15, 5)   default(0.0)
#  symbol            :string
#  tags              :text
#  take_profit       :decimal(15, 8)
#  trade_date        :date             not null
#  trade_grade       :string
#  trade_type        :string
#  uuid              :uuid             not null
#  volume            :decimal(15, 5)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  account_id        :bigint           not null
#  external_trade_id :string
#  space_id          :bigint           not null
#
# Indexes
#
#  index_trades_on_account_id                       (account_id)
#  index_trades_on_account_id_and_is_winning_trade  (account_id,is_winning_trade)
#  index_trades_on_account_id_and_pnl               (account_id,pnl)
#  index_trades_on_account_id_and_trade_date        (account_id,trade_date)
#  index_trades_on_external_trade_id                (external_trade_id) UNIQUE WHERE (external_trade_id IS NOT NULL)
#  index_trades_on_pnl                              (pnl)
#  index_trades_on_space_id                         (space_id)
#  index_trades_on_strategy                         (strategy)
#  index_trades_on_symbol                           (symbol)
#  index_trades_on_trade_date                       (trade_date)
#  index_trades_on_uuid                             (uuid) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (space_id => spaces.id)
#
class Trade < ApplicationRecord
  acts_as_tenant :space

  # Constants
  TRADE_TYPES = {
    "buy" => "Buy/Long",
    "sell" => "Sell/Short"
  }.freeze

  # Callbacks
  before_validation :ensure_uuid
  before_save :calculate_derived_fields
  before_save :generate_external_id

  # Associations
  belongs_to :space
  belongs_to :account
  has_many :rule_violations, dependent: :destroy
  has_many :trade_tags, dependent: :destroy
  has_many :tags, through: :trade_tags

  # Validations
  validates :trade_date, presence: true
  validates :pnl, presence: true, numericality: true
  validates :trade_type, inclusion: {in: TRADE_TYPES.keys}, allow_blank: true
  validates :uuid, uniqueness: true
  validates :external_trade_id, uniqueness: true, allow_blank: true
  validate :entry_time_before_exit_time

  # Scopes
  scope :profitable, -> { where("pnl > 0") }
  scope :losing, -> { where("pnl < 0") }
  scope :break_even, -> { where(pnl: 0) }
  scope :by_symbol, ->(symbol) { where(symbol: symbol) }
  scope :by_strategy, ->(strategy) { where(strategy: strategy) }
  scope :recent, ->(days = 30) { where(trade_date: days.days.ago..) }

  # Instance methods
  def profitable?
    pnl > 0
  end

  def losing?
    pnl < 0
  end

  def break_even?
    pnl.zero?
  end

  def duration_in_minutes
    return nil unless entry_time && exit_time

    ((exit_time - entry_time) / 1.minute).round
  end

  def calculate_risk_reward_ratio
    return nil unless entry_price && exit_price && stop_loss

    risk = (entry_price - stop_loss).abs
    return nil if risk.zero?

    reward = (exit_price - entry_price).abs
    reward / risk
  end

  def to_s
    "##{id} - #{symbol} #{trade_date}"
  end

  private

  def ensure_uuid
    self.uuid ||= SecureRandom.uuid
  end

  def calculate_derived_fields
    self.is_winning_trade = pnl > 0
    self.duration_minutes = duration_in_minutes
    self.risk_reward_ratio = calculate_risk_reward_ratio
  end

  def entry_time_before_exit_time
    return unless entry_time.present? && exit_time.present?

    errors.add(:exit_time, "must be after entry time") if exit_time <= entry_time
  end

  def generate_external_id
    return if external_trade_id.present?

    timestamp = Time.current.strftime("%Y%m%d%H%M%S%N")
    random = SecureRandom.hex(4)
    self.external_trade_id = "Payout-#{account.id}-#{timestamp}-#{random}"
  end
end
