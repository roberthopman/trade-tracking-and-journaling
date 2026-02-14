# frozen_string_literal: true

module Madmin
  class TradesController < Madmin::ResourceController
    include Rails.application.routes.url_helpers

    def index
      # Only show trades for current user's accounts
      @trades = Trade.where(account: current_user.accounts)

      # Filter by account
      @trades = @trades.where(account_id: params[:account_id]) if params[:account_id].present?

      # Filter by symbol
      @trades = @trades.where("symbol ILIKE ?", "%#{params[:symbol]}%") if params[:symbol].present?

      # Filter by trade type
      @trades = @trades.where(trade_type: params[:trade_type]) if params[:trade_type].present?

      # Filter by date range
      if params[:start_date].present?
        @trades = @trades.where(trade_date: Date.parse(params[:start_date])..)
      end
      if params[:end_date].present?
        @trades = @trades.where(trade_date: ..Date.parse(params[:end_date]))
      end

      # Filter by P&L range
      if params[:min_pnl].present?
        @trades = @trades.where(pnl: params[:min_pnl].to_f..)
      end
      if params[:max_pnl].present?
        @trades = @trades.where(pnl: ..params[:max_pnl].to_f)
      end

      # Filter by tag
      if params[:tag_id].present?
        @trades = @trades.joins(:tags).merge(Tag.where(id: params[:tag_id])).distinct
      end

      @trades = @trades.order(trade_date: :desc)

      # Apply eager loading AFTER all filters
      # When filtering by tag, tags are already joined so only preload account
      @trades = if params[:tag_id].present?
                  @trades.preload(:account, :tags)
                else
                  @trades.includes(:account, :tags)
                end

      @pagy, @trades = pagy(@trades, items: 25)
    end

    def show
      @trade = Trade.find(params[:id])
    end

    def new
      @accounts = current_user.real_accounts.order(:name)
      super
      # Pre-fill account if coming from account page
      @record.account_id = params[:account_id] if params[:account_id].present?
    end

    def create
      @trade = Trade.new(trade_params)

      if @trade.save
        handle_tags(@trade, params[:trade][:tag_list])
        update_account_threshold(@trade)
        redirect_to madmin_trade_path(@trade), notice: "Trade was successfully created."
      else
        render :new, status: :unprocessable_content
      end
    end

    def update
      @trade = Trade.find(params[:id])

      if @trade.update(trade_params)
        handle_tags(@trade, params[:trade][:tag_list])
        update_account_threshold(@trade)
        redirect_to madmin_trade_path(@trade), notice: "Trade was successfully updated."
      else
        render :edit, status: :unprocessable_content
      end
    end

    private

    def trade_params
      params.expect(
        trade: [
          :account_id,
          :trade_date,
          :symbol,
          :trade_type,
          :pnl,
          :volume,
          :entry_price,
          :exit_price,
          :stop_loss,
          :take_profit,
          :entry_time,
          :exit_time,
          :commission,
          :swap,
          :strategy,
          :market,
          :setup,
          :emotional_state,
          :market_condition,
          :trade_grade,
          :notes,
          :lesson_learned,
          :external_trade_id
        ]
      )
    end

    def handle_tags(trade, tag_list_string)
      # If the tag_list param wasn't submitted at all, don't modify tags
      return if tag_list_string.nil?

      # If the field was submitted but left empty, clear all tags
      cleaned = tag_list_string.to_s.split(",").map(&:strip).compact_blank

      if cleaned.empty?
        trade.tags = []
        return
      end

      tags = cleaned.map { |name| current_user.tags.find_or_create_by(name: name) }
      trade.tags = tags
    end

    def update_account_threshold(trade)
      return unless trade.account
      return if params[:auto_liquidity_threshold].blank?

      threshold_value = params[:auto_liquidity_threshold].to_f
      trade.account.update(auto_liquidity_threshold: threshold_value)
    end

    public

    def destroy
      # @record is already set by before_action :set_record
      # Verify the trade belongs to one of current user's accounts
      unless current_user.accounts.exists?(id: @record.account_id)
        raise ActiveRecord::RecordNotFound
      end

      @record.destroy
      redirect_to resource.index_path, notice: "Trade was successfully deleted.", status: :see_other
    end
  end
end
