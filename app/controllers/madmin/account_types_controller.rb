# frozen_string_literal: true

module Madmin
  class AccountTypesController < Madmin::ApplicationController
    include Rails.application.routes.url_helpers

    before_action :set_firm
    before_action :set_account_type, only: [:show, :edit, :update, :destroy]

    def show
    end

    def new
      @account_type = @firm.accounts.new(template: true)
    end

    def edit
    end

    def create
      @account_type = @firm.accounts.new(account_type_params)
      @account_type.template = true

      if @account_type.save
        redirect_to madmin_firms_path, notice: "Account type created successfully."
      else
        render :new, status: :unprocessable_content
      end
    end

    def update
      if @account_type.update(account_type_params)
        redirect_to madmin_firms_path, notice: "Account type updated successfully."
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @account_type.destroy
      redirect_to madmin_firms_path, notice: "Account type deleted successfully."
    end

    private

    def set_firm
      @firm = Firm.find(params[:firm_id])
    end

    def set_account_type
      @account_type = @firm.accounts.templates.find(params[:id])
    end

    def account_type_params
      # We use require().permit() instead of expect() because params.expect doesn't handle
      # nested hashes with numeric string keys ("0", "1", "2") from fields_for
      params.require(:account).permit(
        :name,
        :phase,
        :initial_balance,
        account_rules_attributes: [:id, :rule_id, :rule_value, :start_date, :is_active, :_destroy]
      )
      # rubocop:enable Rails/StrongParametersExpect
    end
  end
end
