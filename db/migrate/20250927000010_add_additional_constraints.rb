# frozen_string_literal: true

class AddAdditionalConstraints < ActiveRecord::Migration[8.0]
  def change
    # Add check constraints for data integrity

    # Accounts: initial balance must be positive
    add_check_constraint :accounts, "initial_balance > 0", name: "positive_initial_balance"

    # Accounts: start_date must be before end_date
    add_check_constraint :accounts, "end_date IS NULL OR start_date < end_date", name: "valid_account_date_range"

    # Firm Rules: start_date must be before end_date
    add_check_constraint :firm_rules, "end_date IS NULL OR start_date < end_date", name: "valid_firm_rule_date_range"

    # Account Rules: start_date must be before end_date
    add_check_constraint :account_rules,
      "end_date IS NULL OR start_date < end_date",
      name: "valid_account_rule_date_range"

    # Trades: entry_time must be before exit_time (if both present)
    add_check_constraint :trades,
      "exit_time IS NULL OR entry_time IS NULL OR entry_time <= exit_time",
      name: "valid_trade_time_sequence"

    # Rule Violations: detected_at must be before resolved_at
    add_check_constraint :rule_violations,
      "resolved_at IS NULL OR detected_at <= resolved_at",
      name: "valid_violation_resolution_time"

    # Account Balances: closing balance calculation
    add_check_constraint :account_balances,
      "closing_balance = opening_balance + daily_pnl",
      name: "balance_calculation_integrity"
  end
end
