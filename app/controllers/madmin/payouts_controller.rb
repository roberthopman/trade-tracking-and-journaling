# frozen_string_literal: true

module Madmin
  class PayoutsController < Madmin::ResourceController
    def index
      # Only show payouts for current user's accounts
      @payouts = Payout.where(account: current_user.accounts)

      # Filter by account
      @payouts = @payouts.where(account_id: params[:account_id]) if params[:account_id].present?

      # Filter by request status
      @payouts = @payouts.where(request_status: params[:request_status]) if params[:request_status].present?

      @payouts = @payouts.order(requested_date: :desc)

      # Apply eager loading
      @payouts = @payouts.includes(:account)

      @pagy, @payouts = pagy(@payouts, items: 25)
    end

    def new
      @accounts = current_user.real_accounts.order(:name)
      super
      # Pre-fill account if coming from account page
      @record.account_id = params[:account_id] if params[:account_id].present?
    end

    def edit
      @accounts = current_user.real_accounts.order(:name)
      super
    end

    def create
      @accounts = current_user.real_accounts.order(:name)
      super
    end

    def update
      @accounts = current_user.real_accounts.order(:name)
      super
    end

    def destroy
      # @record is already set by before_action :set_record
      # Verify the payout belongs to one of current user's accounts
      unless current_user.accounts.exists?(id: @record.account_id)
        raise ActiveRecord::RecordNotFound
      end

      @record.destroy
      redirect_to resource.index_path, notice: "Payout was successfully deleted.", status: :see_other
    end
  end
end
