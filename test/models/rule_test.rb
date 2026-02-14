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
require "test_helper"

class RuleTest < ActiveSupport::TestCase
  test "should define trading rules constant" do
    assert_equal 9, Rule::TRADING_RULES.count
    assert_includes Rule::TRADING_RULES, "Daily Loss Limit ($)"
    assert_includes Rule::TRADING_RULES, "Max Total Loss ($)"
    assert_includes Rule::TRADING_RULES, "Profit Target (%)"
  end

  test "should define trading restrictions constant" do
    assert_equal 2, Rule::TRADING_RESTRICTIONS.count
    assert_includes Rule::TRADING_RESTRICTIONS, "Weekend Holding"
    assert_includes Rule::TRADING_RESTRICTIONS, "News Trading"
  end

  test "should define payout rules constant" do
    assert_equal 5, Rule::PAYOUT_RULES.count
    assert_includes Rule::PAYOUT_RULES, "Minimum Payout ($)"
    assert_includes Rule::PAYOUT_RULES, "Payout Frequency (days)"
    assert_includes Rule::PAYOUT_RULES, "Profit Split (%)"
  end

  test "should define payout restrictions constant" do
    assert_equal 1, Rule::PAYOUT_RESTRICTIONS.count
    assert_includes Rule::PAYOUT_RESTRICTIONS, "KYC Required"
  end

  test "trading_rules scope should return only trading rules" do
    # Create trading rules
    Rule::TRADING_RULES.each_with_index do |name, index|
      create(:rule, name: name, sort_order: index + 1)
    end

    trading_rules = Rule.trading_rules
    assert_equal 9, trading_rules.count

    trading_rules.each do |rule|
      assert_includes Rule::TRADING_RULES, rule.name
    end
  end

  test "trading_restrictions scope should return only trading restrictions" do
    # Create trading restrictions
    Rule::TRADING_RESTRICTIONS.each_with_index do |name, index|
      create(:rule, name: name, data_type: "boolean_flag", sort_order: index + 10)
    end

    trading_restrictions = Rule.trading_restrictions
    assert_equal 2, trading_restrictions.count

    trading_restrictions.each do |rule|
      assert_includes Rule::TRADING_RESTRICTIONS, rule.name
    end
  end

  test "payout_rules scope should return only payout rules" do
    # Create payout rules
    Rule::PAYOUT_RULES.each_with_index do |name, index|
      create(:rule, name: name, sort_order: index + 12)
    end

    payout_rules = Rule.payout_rules
    assert_equal 5, payout_rules.count

    payout_rules.each do |rule|
      assert_includes Rule::PAYOUT_RULES, rule.name
    end
  end

  test "payout_restrictions scope should return only payout restrictions" do
    # Create payout restrictions
    Rule::PAYOUT_RESTRICTIONS.each_with_index do |name, index|
      create(:rule, name: name, data_type: "boolean_flag", sort_order: index + 17)
    end

    payout_restrictions = Rule.payout_restrictions
    assert_equal 1, payout_restrictions.count

    payout_restrictions.each do |rule|
      assert_includes Rule::PAYOUT_RESTRICTIONS, rule.name
    end
  end

  test "should validate rule has all required fields" do
    rule = Rule.new
    assert_not rule.valid?

    assert_includes rule.errors[:name], "can't be blank"
    assert_includes rule.errors[:rule_type], "can't be blank"
    assert_includes rule.errors[:data_type], "can't be blank"
  end

  test "should create valid rule with all attributes" do
    space = create(:space)
    rule = Rule.create!(
      space: space,
      name: "Test Rule",
      rule_type: "risk_management",
      data_type: "percentage",
      calculation_method: "simple_threshold",
      time_scope: "daily",
      violation_action: "hard_breach",
      validation_config: {min: 0, max: 100},
      description: "Test rule description"
    )

    assert rule.persisted?
    assert_equal "Test Rule", rule.name
    assert rule.is_active?
  end

  test "should validate rule_type inclusion" do
    rule = build(:rule, rule_type: "invalid_type")
    assert_not rule.valid?
    assert_includes rule.errors[:rule_type], "is not included in the list"
  end

  test "should validate data_type inclusion" do
    rule = build(:rule, data_type: "invalid_type")
    assert_not rule.valid?
    assert_includes rule.errors[:data_type], "is not included in the list"
  end

  test "should have threshold_value method" do
    rule = create(:rule, validation_config: {max: 100})
    assert_equal 100, rule.threshold_value

    rule = create(:rule, validation_config: {min: 0})
    assert_equal 0, rule.threshold_value
  end

  test "should have minimum? and maximum? methods" do
    rule = create(:rule, validation_config: {min: 0, max: 100})
    assert rule.minimum?
    assert rule.maximum?

    rule = create(:rule, validation_config: {max: 100})
    assert_not rule.minimum?
    assert rule.maximum?
  end

  test "active scope should return only active rules" do
    active_rule = create(:rule, is_active: true)
    inactive_rule = create(:rule, is_active: false)

    active_rules = Rule.active
    assert_includes active_rules, active_rule
    assert_not_includes active_rules, inactive_rule
  end

  test "all rule constants should be defined" do
    # Check all trading rules are defined
    Rule::TRADING_RULES.each do |rule_name|
      assert_kind_of String, rule_name
    end

    # Check all trading restrictions are defined
    Rule::TRADING_RESTRICTIONS.each do |rule_name|
      assert_kind_of String, rule_name
    end

    # Check all payout rules are defined
    Rule::PAYOUT_RULES.each do |rule_name|
      assert_kind_of String, rule_name
    end

    # Check all payout restrictions are defined
    Rule::PAYOUT_RESTRICTIONS.each do |rule_name|
      assert_kind_of String, rule_name
    end
  end
end
