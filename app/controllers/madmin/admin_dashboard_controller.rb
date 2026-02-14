# frozen_string_literal: true

module Madmin
  class AdminDashboardController < Madmin::ApplicationController
    def show
      @firms_count = Firm.count
      @rules_count = Rule.count
      @violations_count = RuleViolation.count
      @accounts_count = Account.count
      @trades_count = Trade.count
      @users_count = User.count

      @recent_trades = Trade.includes(:account).order(created_at: :desc).limit(10)
      @recent_violations = RuleViolation.includes(:rule, :account).order(created_at: :desc).limit(10)
    end
  end
end
