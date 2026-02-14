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
FactoryBot.define do
  factory :trade do
    account
    transient do
      space { nil }
    end

    after(:build) do |trade, evaluator|
      trade.space ||= evaluator.space || trade.account&.space
    end

    trade_date { Date.current }
    symbol { %w[EURUSD GBPUSD USDJPY AUDUSD XAUUSD].sample }
    trade_type { %w[buy sell].sample }
    pnl { rand(-500.0..1000.0).round(2) }
    volume { [0.1, 0.5, 1.0, 2.0].sample }
    entry_price { rand(1.0000..1.5000).round(5) }
    exit_price { rand(1.0000..1.5000).round(5) }
    entry_time { trade_date.beginning_of_day + rand(8..15).hours }
    exit_time { entry_time + rand(1..6).hours }
    commission { rand(1.0..5.0).round(2) }
    swap { rand(-2.0..2.0).round(2) }

    trait :profitable do
      pnl { rand(10.0..1000.0).round(2) }
    end

    trait :losing do
      pnl { rand(-800.0..-10.0).round(2) }
    end

    trait :break_even do
      pnl { 0.0 }
    end

    trait :buy do
      trade_type { "buy" }
    end

    trait :sell do
      trade_type { "sell" }
    end

    trait :with_stop_loss do
      stop_loss { entry_price - rand(0.001..0.01).round(5) }
    end

    trait :with_take_profit do
      take_profit { entry_price + rand(0.001..0.01).round(5) }
    end
  end
end
