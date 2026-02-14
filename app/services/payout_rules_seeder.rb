# frozen_string_literal: true

class PayoutRulesSeeder
  PAYOUT_RULES_DATA = [
    {
      name: "Minimum Payout ($)",
      rule_type: "payout_eligibility",
      data_type: "currency_amount",
      calculation_method: "simple_threshold",
      time_scope: "lifetime",
      validation_config: {min: 0},
      description: "Minimum amount required for payout",
      sort_order: 13
    },
    {
      name: "Payout Frequency (days)",
      rule_type: "payout_eligibility",
      data_type: "integer_count",
      calculation_method: "simple_threshold",
      time_scope: "lifetime",
      validation_config: {min: 1},
      description: "How often payouts are processed",
      sort_order: 14
    },
    {
      name: "Profit Split (%)",
      rule_type: "payout_eligibility",
      data_type: "percentage",
      calculation_method: "simple_threshold",
      time_scope: "lifetime",
      validation_config: {max: 100, min: 0},
      description: "Percentage of profit the trader keeps",
      sort_order: 15
    },
    {
      name: "First Payout Wait (days)",
      rule_type: "payout_eligibility",
      data_type: "integer_count",
      calculation_method: "simple_threshold",
      time_scope: "lifetime",
      validation_config: {min: 0},
      description: "Waiting period before first payout",
      sort_order: 16
    },
    {
      name: "Min Trading Days (Payout)",
      rule_type: "payout_eligibility",
      data_type: "integer_count",
      calculation_method: "trading_days",
      time_scope: "lifetime",
      validation_config: {min: 0},
      description: "Minimum trading days required before payout",
      sort_order: 17
    },
    {
      name: "KYC Required",
      rule_type: "payout_eligibility",
      data_type: "boolean_flag",
      calculation_method: "simple_threshold",
      time_scope: "lifetime",
      validation_config: {allowed_values: [true, false]},
      description: "Identity verification needed for payout",
      sort_order: 18
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
      PAYOUT_RULES_DATA.each { |rule_data| create_or_update_rule(rule_data) }
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
