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
FactoryBot.define do
  factory :account do
    user
    firm
    transient do
      space { nil }
    end

    after(:build) do |account, evaluator|
      account.space ||= evaluator.space || account.firm&.space
    end

    sequence(:name) { |n| "Account #{n}" }
    sequence(:external_id) { |n| "ACC-#{n.to_s.rjust(6, "0")}" }
    phase { "evaluation" }
    status { "active" }
    initial_balance { 50_000 }
    currency { "USD" }
    start_date { 30.days.ago }
    template { false }

    trait :sim_funded do
      phase { "sim-funded" }
    end

    trait :live do
      phase { "live" }
    end

    trait :template do
      template { true }
      user { nil }
      external_id { nil }
    end

    trait :suspended do
      status { "suspended" }
    end

    trait :terminated do
      status { "terminated" }
    end
  end
end
