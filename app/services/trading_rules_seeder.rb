# frozen_string_literal: true

class TradingRulesSeeder
  TRADING_RULES_DATA = [
    {
      name: "Daily Loss Limit ($)",
      rule_type: "risk_management",
      data_type: "currency_amount",
      calculation_method: "daily_loss",
      time_scope: "daily",
      validation_config: {min: 0},
      description: "Maximum dollar amount that can be lost in a single day",
      sort_order: 1
    },
    {
      name: "Max Total Loss ($)",
      rule_type: "risk_management",
      data_type: "currency_amount",
      calculation_method: "total_drawdown",
      time_scope: "lifetime",
      validation_config: {min: 0},
      description: "Maximum dollar drawdown allowed on the account",
      sort_order: 2
    },
    {
      name: "Profit Target (%)",
      rule_type: "payout_eligibility",
      data_type: "percentage",
      calculation_method: "simple_threshold",
      time_scope: "lifetime",
      validation_config: {min: 0},
      description: "Initial profit target to reach",
      sort_order: 3
    },
    {
      name: "Min Trading Days",
      rule_type: "trading_behavior",
      data_type: "integer_count",
      calculation_method: "trading_days",
      time_scope: "lifetime",
      validation_config: {min: 0},
      description: "Minimum number of trading days required for evaluation",
      sort_order: 4
    },
    {
      name: "Min Trading Day Amount ($)",
      rule_type: "trading_behavior",
      data_type: "currency_amount",
      calculation_method: "simple_threshold",
      time_scope: "daily",
      validation_config: {min: 0},
      description: "Minimum dollar amount required for a day to count as a trading day",
      sort_order: 5
    },
    {
      name: "Consistency Rule (%)",
      rule_type: "trading_behavior",
      data_type: "percentage",
      calculation_method: "consistency_ratio",
      time_scope: "lifetime",
      validation_config: {max: 100, min: 0},
      description: "Maximum percentage of profit from a single day",
      sort_order: 6
    },
    {
      name: "Safety Net (%)",
      rule_type: "risk_management",
      data_type: "percentage",
      calculation_method: "simple_threshold",
      time_scope: "daily",
      validation_config: {max: 100, min: 0},
      description: "Protection buffer for account",
      sort_order: 7
    },
    {
      name: "Max Position Size (%)",
      rule_type: "risk_management",
      data_type: "percentage",
      calculation_method: "position_size",
      time_scope: "per_trade",
      validation_config: {max: 100, min: 0},
      description: "Maximum position size as percentage of account value",
      sort_order: 8
    },
    {
      name: "Leverage Limit",
      rule_type: "risk_management",
      data_type: "integer_count",
      calculation_method: "simple_threshold",
      time_scope: "per_trade",
      validation_config: {min: 1},
      description: "Maximum leverage ratio allowed",
      sort_order: 9
    },
    {
      name: "Phase 1 Target (%)",
      rule_type: "payout_eligibility",
      data_type: "percentage",
      calculation_method: "simple_threshold",
      time_scope: "lifetime",
      validation_config: {max: 100, min: 0},
      description: "Profit target for challenge phase",
      sort_order: 10
    },
    {
      name: "Weekend Holding",
      rule_type: "trading_behavior",
      data_type: "boolean_flag",
      calculation_method: "simple_threshold",
      time_scope: "per_trade",
      validation_config: {allowed_values: [true, false]},
      description: "Allow positions to be held over weekends",
      sort_order: 11
    },
    {
      name: "News Trading",
      rule_type: "trading_behavior",
      data_type: "boolean_flag",
      calculation_method: "simple_threshold",
      time_scope: "per_trade",
      validation_config: {allowed_values: [true, false]},
      description: "Allow trading during news events",
      sort_order: 12
    },
    {
      name: "Safety Net ($)",
      rule_type: "risk_management",
      data_type: "currency_amount",
      calculation_method: "simple_threshold",
      time_scope: "daily",
      validation_config: {min: 0},
      description: "Protection buffer for account in dollars",
      sort_order: 13
    },
    {
      name: "Profit Target ($)",
      rule_type: "payout_eligibility",
      data_type: "currency_amount",
      calculation_method: "simple_threshold",
      time_scope: "lifetime",
      validation_config: {min: 0},
      description: "Initial profit target to reach in dollars",
      sort_order: 14
    }
  ].freeze

  def self.seed_for_space(space)
    new(space).seed
  end

  def initialize(space)
    @space = space
  end

  def seed
    ActsAsTenant.with_tenant(@space) do
      TRADING_RULES_DATA.each { |rule_data| create_or_update_rule(rule_data) }
    end
  end

  private

  def create_or_update_rule(rule_data)
    Rule.find_or_create_by!(name: rule_data[:name]) do |rule|
      rule.assign_attributes(
        rule_type: rule_data[:rule_type],
        data_type: rule_data[:data_type],
        calculation_method: rule_data[:calculation_method],
        time_scope: rule_data[:time_scope],
        validation_config: rule_data[:validation_config],
        description: rule_data[:description],
        sort_order: rule_data[:sort_order],
        is_active: true,
        violation_action: "hard_breach"
      )
    end
  end
end
