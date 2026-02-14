# frozen_string_literal: true

module Madmin
  class QuickTradesController < Madmin::ApplicationController
    include Rails.application.routes.url_helpers

    def new
      @accounts = current_user.accounts.real_accounts.includes(:user, :firm).order(:firm_id, :name)
    end

    def create
      @accounts = current_user.accounts.real_accounts.includes(:user, :firm).order(:firm_id, :name)

      return render_validation_error if invalid_params?

      result = process_trades
      handle_trade_result(result)
    end

    private

    def invalid_params?
      params[:trade_date].blank? || params[:symbol].blank? || params[:trade_type].blank?
    end

    def render_validation_error
      flash.now[:alert] = "Trade date, symbol, and trade type are required"
      render :new
    end

    def process_trades
      account_pnls = params[:account_pnls] || {}
      account_thresholds = params[:account_thresholds] || {}
      created_trades = []
      errors = []

      # Prepare tags once
      tags = []
      if params[:tag_list].present?
        tag_names = params[:tag_list].split(",").map(&:strip).compact_blank
        tags = tag_names.map do |name|
          current_user.tags.find_or_create_by(name: name)
        end
      end

      account_pnls.each do |account_id, pnl_value|
        next if pnl_value.blank?

        account = Account.find_by(id: account_id)
        next unless account

        # Update threshold if provided
        threshold_value = account_thresholds[account_id]
        if threshold_value.present?
          account.update(auto_liquidity_threshold: threshold_value.to_f)
        end

        trade = build_trade(account, pnl_value)
        if trade.save
          trade.tags = tags if tags.any?
          created_trades << trade
        else
          errors << format_trade_error(account, trade)
        end
      end

      {created_trades: created_trades, errors: errors}
    end

    def build_trade(account, pnl_value)
      Trade.new(
        account: account,
        trade_date: params[:trade_date],
        symbol: params[:symbol],
        pnl: pnl_value.to_f,
        trade_type: params[:trade_type],
        volume: 1.0,
        entry_price: 1.0000,
        exit_price: 1.0000 + (pnl_value.to_f / 10_000),
        strategy: "manual_entry",
        external_trade_id: generate_external_id(account)
      )
    end

    def generate_external_id(account)
      "QT-#{account.id}-#{Date.current.strftime("%Y%m%d")}-#{Time.current.to_i}"
    end

    def format_trade_error(account, trade)
      "Account #{account.name || account.id}: #{trade.errors.full_messages.join(", ")}"
    end

    def handle_trade_result(result)
      if result[:created_trades].any?
        assign_success_flash(result)
        redirect_to madmin_trades_path
      else
        assign_error_flash(result[:errors])
        render :new
      end
    end

    def assign_success_flash(result)
      flash[:notice] = "Successfully created #{result[:created_trades].count} trades"
      if result[:errors].any?
        flash[:alert] = "Some trades failed: #{result[:errors].join("; ")}"
      end
    end

    def assign_error_flash(errors)
      message = errors.any? ? "Failed to create trades: #{errors.join("; ")}" : "No valid trades to create"
      flash.now[:alert] = message
    end

    def determine_trade_type(pnl)
      pnl >= 0 ? "buy" : "sell"
    end
  end
end
