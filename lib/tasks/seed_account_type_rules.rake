# frozen_string_literal: true

namespace :seed do
  desc "Seed account type rules (17 hardcoded rules for account configuration)"
  task account_type_rules: :environment do
    puts "🌱 Seeding Account Type Rules..."

    # Use the shared service to seed rules
    Space.find_each do |space|
      puts "  Seeding rules for space: #{space.name} (ID: #{space.id})"
      AccountTypeRulesSeeder.seed_for_space(space)
    end

    puts "\n✅ Account Type Rules seeded successfully!"
    puts "   Total rules per space: 17"
  end

  desc "Seed account type rules (legacy - kept for reference)"
  task account_type_rules_legacy: :environment do
    puts "🌱 Seeding Account Type Rules (Legacy)..."

    rules_data = [
      # Trading Rules (1-9)
      {
        name: "Daily Loss Limit ($)",
        slug: "daily_loss_limit_usd",
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
        slug: "max_total_loss_usd",
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
        slug: "profit_target_pct",
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
        slug: "min_trading_days",
        rule_type: "trading_behavior",
        data_type: "integer_count",
        calculation_method: "trading_days",
        time_scope: "lifetime",
        validation_config: {min: 0},
        description: "Minimum number of trading days required for evaluation",
        sort_order: 4
      },
      {
        name: "Consistency Rule (%)",
        slug: "consistency_rule_pct",
        rule_type: "trading_behavior",
        data_type: "percentage",
        calculation_method: "consistency_ratio",
        time_scope: "lifetime",
        validation_config: {max: 100, min: 0},
        description: "Maximum percentage of profit from a single day",
        sort_order: 5
      },
      {
        name: "Safety Net (%)",
        slug: "safety_net_pct",
        rule_type: "risk_management",
        data_type: "percentage",
        calculation_method: "simple_threshold",
        time_scope: "daily",
        validation_config: {max: 100, min: 0},
        description: "Protection buffer for account",
        sort_order: 6
      },
      {
        name: "Max Position Size (%)",
        slug: "max_position_size_pct",
        rule_type: "risk_management",
        data_type: "percentage",
        calculation_method: "position_size",
        time_scope: "per_trade",
        validation_config: {max: 100, min: 0},
        description: "Maximum position size as percentage of account value",
        sort_order: 7
      },
      {
        name: "Leverage Limit",
        slug: "leverage_limit",
        rule_type: "risk_management",
        data_type: "integer_count",
        calculation_method: "simple_threshold",
        time_scope: "per_trade",
        validation_config: {min: 1},
        description: "Maximum leverage ratio allowed",
        sort_order: 8
      },
      {
        name: "Phase 1 Target (%)",
        slug: "phase_1_target_pct",
        rule_type: "payout_eligibility",
        data_type: "percentage",
        calculation_method: "simple_threshold",
        time_scope: "lifetime",
        validation_config: {max: 100, min: 0},
        description: "Profit target for challenge phase",
        sort_order: 9
      },
      # Trading Restrictions (10-11) - stored as boolean
      {
        name: "Weekend Holding",
        slug: "weekend_holding_allowed",
        rule_type: "trading_behavior",
        data_type: "boolean_flag",
        calculation_method: "simple_threshold",
        time_scope: "per_trade",
        validation_config: {allowed_values: [true, false]},
        description: "Allow positions to be held over weekends",
        sort_order: 10
      },
      {
        name: "News Trading",
        slug: "news_trading_allowed",
        rule_type: "trading_behavior",
        data_type: "boolean_flag",
        calculation_method: "simple_threshold",
        time_scope: "per_trade",
        validation_config: {allowed_values: [true, false]},
        description: "Allow trading during news events",
        sort_order: 11
      },
      # Payout Rules (12-16)
      {
        name: "Minimum Payout ($)",
        slug: "minimum_payout_amount",
        rule_type: "payout_eligibility",
        data_type: "currency_amount",
        calculation_method: "simple_threshold",
        time_scope: "lifetime",
        validation_config: {min: 0},
        description: "Minimum amount required for payout",
        sort_order: 12
      },
      {
        name: "Payout Frequency (days)",
        slug: "payout_frequency_days",
        rule_type: "payout_eligibility",
        data_type: "integer_count",
        calculation_method: "simple_threshold",
        time_scope: "lifetime",
        validation_config: {min: 1},
        description: "How often payouts are processed",
        sort_order: 13
      },
      {
        name: "Profit Split (%)",
        slug: "profit_split_pct",
        rule_type: "payout_eligibility",
        data_type: "percentage",
        calculation_method: "simple_threshold",
        time_scope: "lifetime",
        validation_config: {max: 100, min: 0},
        description: "Percentage of profit the trader keeps",
        sort_order: 14
      },
      {
        name: "First Payout Wait (days)",
        slug: "first_payout_wait_days",
        rule_type: "payout_eligibility",
        data_type: "integer_count",
        calculation_method: "simple_threshold",
        time_scope: "lifetime",
        validation_config: {min: 0},
        description: "Waiting period before first payout",
        sort_order: 15
      },
      {
        name: "Min Trading Days (Payout)",
        slug: "min_trading_days_payout",
        rule_type: "payout_eligibility",
        data_type: "integer_count",
        calculation_method: "trading_days",
        time_scope: "lifetime",
        validation_config: {min: 0},
        description: "Minimum trading days required before payout",
        sort_order: 16
      },
      # Payout Restrictions (17)
      {
        name: "KYC Required",
        slug: "kyc_required",
        rule_type: "payout_eligibility",
        data_type: "boolean_flag",
        calculation_method: "simple_threshold",
        time_scope: "lifetime",
        validation_config: {allowed_values: [true, false]},
        description: "Identity verification needed for payout",
        sort_order: 17
      }
    ]

    rules_data.each do |rule_data|
      rule = Rule.find_or_initialize_by(name: rule_data[:name])

      if rule.new_record?
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
        rule.save!
        puts "  ✓ Created: #{rule.name}"
      else
        puts "  - Exists: #{rule.name}"
      end
    end

    puts "\n✅ Account Type Rules seeded successfully!"
    puts "   Total rules: #{Rule.count}"
  end
end
