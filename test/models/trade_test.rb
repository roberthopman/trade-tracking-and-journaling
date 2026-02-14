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
require "test_helper"

class TradeTest < ActiveSupport::TestCase
  # Setup
  def setup
    @trade = build(:trade)
  end

  # Validations
  test "should be valid with valid attributes" do
    assert @trade.valid?
  end

  test "should require trade_date" do
    @trade.trade_date = nil
    assert_not @trade.valid?
    assert_includes @trade.errors[:trade_date], "can't be blank"
  end

  test "should require pnl" do
    @trade.pnl = nil
    assert_not @trade.valid?
    assert_includes @trade.errors[:pnl], "can't be blank"
  end

  test "should require pnl to be numeric" do
    @trade.pnl = "not a number"
    assert_not @trade.valid?
    assert_includes @trade.errors[:pnl], "is not a number"
  end

  test "should validate trade_type inclusion" do
    @trade.trade_type = "invalid_type"
    assert_not @trade.valid?
    assert_includes @trade.errors[:trade_type], "is not included in the list"
  end

  test "should allow valid trade types" do
    Trade::TRADE_TYPES.each_key do |type|
      @trade.trade_type = type
      assert @trade.valid?, "#{type} should be valid"
    end
  end

  test "should validate uuid uniqueness" do
    trade1 = create(:trade)
    trade2 = build(:trade, uuid: trade1.uuid)
    assert_not trade2.valid?
    assert_includes trade2.errors[:uuid], "has already been taken"
  end

  test "should validate external_trade_id uniqueness" do
    trade1 = create(:trade)
    trade1.update_column(:external_trade_id, "MANUAL-123")

    trade2 = build(:trade, external_trade_id: "MANUAL-123")
    assert_not trade2.valid?
    assert_includes trade2.errors[:external_trade_id], "has already been taken"
  end

  test "should generate external_trade_id on save" do
    trade = build(:trade, external_trade_id: nil)
    assert_nil trade.external_trade_id
    trade.save
    assert_not_nil trade.external_trade_id
    assert_match(/^Payout-/, trade.external_trade_id)
  end

  test "should validate exit_time is after entry_time" do
    @trade.entry_time = Time.current
    @trade.exit_time = @trade.entry_time - 1.hour
    assert_not @trade.valid?
    assert_includes @trade.errors[:exit_time], "must be after entry time"
  end

  # Callbacks
  test "should generate uuid before validation" do
    trade = Trade.new(account: create(:account), trade_date: Date.current, pnl: 100)
    assert_nil trade.uuid
    trade.valid?
    assert_not_nil trade.uuid
  end

  test "should calculate is_winning_trade before save" do
    trade = create(:trade, pnl: 500)
    assert_equal true, trade.is_winning_trade

    trade.update(pnl: -200)
    assert_equal false, trade.is_winning_trade
  end

  test "should calculate duration_minutes before save" do
    entry = Time.current
    exit_time = entry + 90.minutes
    trade = create(:trade, entry_time: entry, exit_time: exit_time)
    assert_equal 90, trade.duration_minutes
  end

  test "should calculate risk_reward_ratio before save" do
    trade = create(
      :trade,
      entry_price: 1.1000,
      exit_price: 1.1030,
      stop_loss: 1.0990
    )
    assert_not_nil trade.risk_reward_ratio
    assert_operator trade.risk_reward_ratio, :>, 0
  end

  # Scopes
  test "profitable scope returns trades with positive pnl" do
    create(:trade, :profitable, pnl: 100)
    create(:trade, :losing, pnl: -50)
    create(:trade, :break_even, pnl: 0)

    profitable_trades = Trade.profitable
    assert_equal 1, profitable_trades.count
    assert profitable_trades.all? { |t| t.pnl > 0 }
  end

  test "losing scope returns trades with negative pnl" do
    create(:trade, :profitable, pnl: 100)
    create(:trade, :losing, pnl: -50)
    create(:trade, :break_even, pnl: 0)

    losing_trades = Trade.losing
    assert_equal 1, losing_trades.count
    assert losing_trades.all? { |t| t.pnl < 0 }
  end

  test "break_even scope returns trades with zero pnl" do
    create(:trade, :profitable, pnl: 100)
    create(:trade, :losing, pnl: -50)
    create(:trade, :break_even, pnl: 0)

    break_even_trades = Trade.break_even
    assert_equal 1, break_even_trades.count
    assert break_even_trades.all? { |t| t.pnl.zero? }
  end

  test "by_symbol scope filters by symbol" do
    create(:trade, symbol: "EURUSD")
    create(:trade, symbol: "GBPUSD")
    create(:trade, symbol: "EURUSD")

    eurusd_trades = Trade.by_symbol("EURUSD")
    assert_equal 2, eurusd_trades.count
    assert eurusd_trades.all? { |t| t.symbol == "EURUSD" }
  end

  test "by_strategy scope filters by strategy" do
    create(:trade, strategy: "scalping")
    create(:trade, strategy: "swing")
    create(:trade, strategy: "scalping")

    scalping_trades = Trade.by_strategy("scalping")
    assert_equal 2, scalping_trades.count
    assert scalping_trades.all? { |t| t.strategy == "scalping" }
  end

  test "recent scope returns trades from last N days" do
    create(:trade, trade_date: 25.days.ago)
    create(:trade, trade_date: 35.days.ago)
    create(:trade, trade_date: Date.current)

    recent_trades = Trade.recent(30)
    assert_equal 2, recent_trades.count
    assert recent_trades.all? { |t| t.trade_date >= 30.days.ago }
  end

  # Instance Methods
  test "profitable? returns true for positive pnl" do
    trade = build(:trade, pnl: 100)
    assert trade.profitable?
  end

  test "profitable? returns false for negative pnl" do
    trade = build(:trade, pnl: -100)
    assert_not trade.profitable?
  end

  test "losing? returns true for negative pnl" do
    trade = build(:trade, pnl: -100)
    assert trade.losing?
  end

  test "losing? returns false for positive pnl" do
    trade = build(:trade, pnl: 100)
    assert_not trade.losing?
  end

  test "break_even? returns true for zero pnl" do
    trade = build(:trade, pnl: 0)
    assert trade.break_even?
  end

  test "break_even? returns false for non-zero pnl" do
    trade = build(:trade, pnl: 100)
    assert_not trade.break_even?
  end

  test "duration_in_minutes returns nil when entry_time is nil" do
    trade = build(:trade, entry_time: nil, exit_time: Time.current)
    assert_nil trade.duration_in_minutes
  end

  test "duration_in_minutes returns nil when exit_time is nil" do
    trade = build(:trade, entry_time: Time.current, exit_time: nil)
    assert_nil trade.duration_in_minutes
  end

  test "duration_in_minutes calculates correct duration" do
    entry = Time.current
    exit_time = entry + 2.hours
    trade = build(:trade, entry_time: entry, exit_time: exit_time)
    assert_equal 120, trade.duration_in_minutes
  end

  test "calculate_risk_reward_ratio returns nil when entry_price is nil" do
    trade = build(:trade, entry_price: nil, exit_price: 1.1000, stop_loss: 1.0990)
    assert_nil trade.calculate_risk_reward_ratio
  end

  test "calculate_risk_reward_ratio returns nil when stop_loss is nil" do
    trade = build(:trade, entry_price: 1.1000, exit_price: 1.1010, stop_loss: nil)
    assert_nil trade.calculate_risk_reward_ratio
  end

  test "calculate_risk_reward_ratio returns nil when risk is zero" do
    trade = build(:trade, entry_price: 1.1000, exit_price: 1.1010, stop_loss: 1.1000)
    assert_nil trade.calculate_risk_reward_ratio
  end

  test "calculate_risk_reward_ratio calculates correct ratio" do
    trade = build(
      :trade,
      entry_price: 1.1000,
      exit_price: 1.1020,
      stop_loss: 1.0990
    )

    ratio = trade.calculate_risk_reward_ratio
    assert_not_nil ratio
    assert_in_delta(2.0, ratio.round(1))
  end

  test "to_s returns formatted string" do
    trade = create(:trade, symbol: "EURUSD", trade_date: Date.new(2025, 1, 15))
    assert_match(/EURUSD/, trade.to_s)
    assert_match(/2025-01-15/, trade.to_s)
  end

  # Associations
  test "should belong to account" do
    assert_respond_to @trade, :account
  end

  test "should have many rule_violations" do
    assert_respond_to @trade, :rule_violations
  end

  test "should have many tags through trade_tags" do
    assert_respond_to @trade, :tags
  end

  test "should destroy associated trade_tags when destroyed" do
    trade = create(:trade)
    tag = create(:tag, user: trade.account.user)
    trade.tags << tag

    assert_difference "TradeTag.count", -1 do
      trade.destroy
    end
  end

  # Constants
  test "TRADE_TYPES constant should be defined" do
    assert_equal({"buy" => "Buy/Long", "sell" => "Sell/Short"}, Trade::TRADE_TYPES)
  end
end
