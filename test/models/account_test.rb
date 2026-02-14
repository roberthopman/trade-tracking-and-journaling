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
require "test_helper"

class AccountTest < ActiveSupport::TestCase
  test "valid account with all required attributes" do
    account = build(:account)
    assert_predicate account, :valid?
  end

  test "requires external_id for real accounts" do
    account = build(:account, external_id: nil)
    assert_not account.valid?
    assert_includes account.errors[:external_id], "can't be blank"
  end

  test "does not require external_id for template accounts" do
    account = build(:account, :template, external_id: nil)
    assert_predicate account, :valid?
  end

  test "external_id must be unique within a space" do
    space = create(:space)
    firm = create(:firm, space: space)
    create(:account, firm: firm, space: space, external_id: "ACC-123456")

    duplicate = build(:account, firm: firm, space: space, external_id: "ACC-123456")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:external_id], "has already been taken"
  end

  test "external_id can be duplicated across different spaces" do
    space1 = create(:space)
    firm1 = create(:firm, space: space1)
    create(:account, firm: firm1, space: space1, external_id: "ACC-123456")

    space2 = create(:space)
    firm2 = create(:firm, space: space2)
    account2 = build(:account, firm: firm2, space: space2, external_id: "ACC-123456")
    assert_predicate account2, :valid?
  end
end
