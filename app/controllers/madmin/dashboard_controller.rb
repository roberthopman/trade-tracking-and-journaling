# frozen_string_literal: true

module Madmin
  class DashboardController < Madmin::ApplicationController
    before_action :authenticate_user!

    def index
      @selected_month = params[:month] ? Date.parse("#{params[:month]}-01") : Date.current.beginning_of_month
      @accounts = current_user.accounts.real_accounts.includes(:firm)

      # Handle "all accounts" or specific account selection
      if params[:account_id] == "all"
        @selected_account = nil
        @all_accounts = true
      elsif params[:account_id].present?
        @selected_account = current_user.accounts.find(params[:account_id])
        @all_accounts = false
      else
        @selected_account = nil
        @all_accounts = true
      end

      if @accounts.any?
        # Only include trades from active and completed accounts (exclude suspended and terminated)
        active_accounts = @accounts.where.not(status: %w[suspended terminated])
        @trades = if @all_accounts
                    Trade.where(account: active_accounts).order(trade_date: :desc)
                  else
                    # For single account view, still show trades but exclude from calculations if suspended/terminated
                    @selected_account.trades.order(trade_date: :desc)
                  end
        calculate_kpis
        prepare_calendar_data
      end
    end

    private

    def calculate_kpis
      # Filter out trades from suspended/terminated accounts
      all_trades = if @all_accounts
                     @trades
                   else
                     # For single account, exclude from calculations if suspended/terminated
                     @selected_account.status.in?(%w[suspended terminated]) ? Trade.none : @trades
                   end

      trades_pnl = all_trades.sum(:pnl)
      @total_trades = all_trades.count

      # Calculate total payouts for active accounts only
      active_accounts = @accounts.where.not(status: %w[suspended terminated])
      @total_payouts = if @all_accounts
                         Payout.where(account: active_accounts).approved.where.not(amount_paid: nil).sum(:amount_paid)
                       elsif @selected_account.status.in?(%w[suspended terminated])
                         0
                       else
                         @selected_account.payouts.approved.where.not(amount_paid: nil).sum(:amount_paid)
                       end

      # Total P&L is trades P&L minus payouts
      @total_pnl = trades_pnl - @total_payouts

      winning_trades = all_trades.profitable
      losing_trades = all_trades.losing

      @win_count = winning_trades.count
      @loss_count = losing_trades.count
      @win_rate = @total_trades.positive? ? (@win_count.to_f / @total_trades * 100).round(2) : 0

      @avg_win = @win_count.positive? ? (winning_trades.sum(:pnl) / @win_count).round(2) : 0
      @avg_loss = @loss_count.positive? ? (losing_trades.sum(:pnl) / @loss_count).round(2) : 0

      @best_win = winning_trades.maximum(:pnl) || 0
      @worst_loss = losing_trades.minimum(:pnl) || 0
    end

    def prepare_calendar_data
      @calendar_start = @selected_month.beginning_of_month.beginning_of_week(:monday)
      @calendar_end = @selected_month.end_of_month.end_of_week(:monday)

      # Filter out trades from suspended/terminated accounts
      filtered_trades = if @all_accounts
                          @trades
                        else
                          @selected_account.status.in?(%w[suspended terminated]) ? Trade.none : @trades
                        end

      month_trades = filtered_trades.where(trade_date: @selected_month.all_month)

      @trades_by_date = month_trades.group(:trade_date).sum(:pnl)
      @trade_counts_by_date = month_trades.group(:trade_date).count
      @monthly_pnl = month_trades.sum(:pnl)

      @weekly_pnl = {}
      current_week_start = @calendar_start
      while current_week_start <= @calendar_end
        week_end = [current_week_start.end_of_week(:monday), @calendar_end].min
        week_trades = month_trades.where(trade_date: current_week_start..week_end)
        @weekly_pnl[current_week_start] = week_trades.sum(:pnl)
        current_week_start = current_week_start.next_week(:monday)
      end
    end
  end
end
