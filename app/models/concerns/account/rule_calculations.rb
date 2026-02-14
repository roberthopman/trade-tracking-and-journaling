# frozen_string_literal: true

module Account::RuleCalculations
  extend ActiveSupport::Concern

  # Calculate profit target from rules
  def profit_target
    # First check for direct dollar amount rule
    dollar_rule = account_rules.joins(:rule).find_by(rules: {name: "Profit Target ($)"})
    return dollar_rule.rule_value.to_f if dollar_rule&.rule_value.present?

    # Fall back to percentage rule
    percent_rule = account_rules.joins(:rule).find_by(rules: {name: "Profit Target (%)"})
    return nil if percent_rule&.rule_value.blank?

    initial_balance * (percent_rule.rule_value.to_f / 100)
  end

  def safety_net_amount
    rule = account_rules.joins(:rule).find_by(rules: {name: "Safety Net ($)"})
    rule&.rule_value&.to_f
  end

  def amount_needed_to_safety_net
    return nil unless safety_net_amount

    needed = safety_net_amount - profit_loss
    [needed, 0].max
  end

  def amount_over_safety_net
    return nil unless safety_net_amount

    over = profit_loss - safety_net_amount
    [over, 0].max
  end

  def consistency_rule_value
    rule = account_rules.joins(:rule).find_by(rules: {name: "Consistency Rule (%)"})
    rule&.rule_value&.to_f
  end

  def consistency_target
    return nil unless consistency_rule_value && biggest_day > 0

    biggest_day / (consistency_rule_value / 100)
  end

  def remaining_to_target
    return nil unless consistency_target && profit_loss

    consistency_target - profit_loss
  end

  def required_trading_days
    min_trading_days_rule&.rule_value.to_i
  end

  def min_trading_day_amount_threshold
    min_trading_day_amount_rule_value || 0
  end

  private

  def min_trading_days_rule
    account_rules.joins(:rule).find_by(rules: {name: "Min Trading Days"})
  end

  def min_trading_day_amount_rule_value
    rule = account_rules.joins(:rule).find_by(rules: {name: "Min Trading Day Amount ($)"})
    rule&.rule_value&.to_f
  end
end
