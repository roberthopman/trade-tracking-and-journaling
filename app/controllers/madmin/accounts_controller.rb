# frozen_string_literal: true

module Madmin
  class AccountsController < Madmin::ResourceController
    def index
      # Start with real accounts (non-templates)
      @records = resource.model.real_accounts

      # Filter by firm
      @records = @records.where(firm_id: params[:firm_id]) if params[:firm_id].present?

      # Filter by account type (phase)
      @records = @records.where(phase: params[:phase]) if params[:phase].present?

      # Filter by status
      @records = @records.where(status: params[:status]) if params[:status].present?

      # Order by most recent first
      @records = @records.order(created_at: :desc)

      # Apply eager loading for performance
      @records = @records.includes(:firm, :user)

      # Use pagination
      @pagy, @records = pagy(@records, items: 25)
    end

    def new
      @record = resource.model.new(
        user: current_user,
        start_date: Date.current
      )
    end

    def create
      template = Account.find(params[:account][:template_id])
      create_account_from_template(template)

      if @record.save
        redirect_to resource.show_path(@record),
          notice: "Account was successfully created."
      else
        render :new, status: :unprocessable_content
      end
    end

    def update
      @record = resource.model.find(params[:id])

      # Debug: Log what params we're actually using
      Rails.logger.debug "=" * 80
      Rails.logger.debug "Account params being passed to update:"
      Rails.logger.debug account_params.inspect
      Rails.logger.debug "=" * 80

      # Ensure user cannot be changed during updates
      if @record.update(account_params)
        redirect_to resource.show_path(@record),
          notice: "Account was successfully updated."
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @record = resource.model.where(user: current_user).find(params[:id])

      if @record.destroy
        redirect_to resource.index_path, notice: "Account was successfully deleted."
      else
        redirect_to resource.show_path(@record),
          alert: "Account could not be deleted: #{@record.errors.full_messages.join(", ")}"
      end
    end

    private

    def create_account_from_template(template)
      @record = resource.model.new(
        user: current_user,
        firm_id: template.firm_id,
        name: template.name,
        external_id: params[:account][:external_id],
        start_date: params[:account][:start_date],
        phase: template.phase,
        initial_balance: template.initial_balance,
        currency: template.currency,
        status: template.status,
        profit_target: template.profit_target,
        max_trading_days: template.max_trading_days,
        challenge_deadline: template.challenge_deadline,
        connection: params[:account][:connection],
        platform: params[:account][:platform],
        template: false
      )
    end

    def account_params
      params.require(:account).permit(
        :name,
        :initial_balance,
        :external_id,
        :start_date,
        :end_date,
        :description,
        :currency,
        :connection,
        :platform,
        :phase,
        :status,
        :auto_liquidity_threshold,
        account_rules_attributes: [:id, :rule_id, :rule_value, :start_date]
      )
    end

    def permitted_params
      params.expect(
        account: [:template_id, :external_id, :start_date, :connection, :platform, :auto_liquidity_threshold]
      )
    end
  end
end
