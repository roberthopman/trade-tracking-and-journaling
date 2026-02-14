# frozen_string_literal: true

module Madmin
  class ApplicationController < Madmin::BaseController
    # Pretender - allows admins to impersonate users
    impersonates :user

    # Multi-tenancy
    set_current_tenant_through_filter
    before_action :authenticate_admin_user
    before_action :set_current_space

    def authenticate_admin_user
      # TODO: Add your authentication logic here

      # For example, with Rails 8 authentication
      # redirect_to "/", alert: "Not authorized." unless authenticated? && Current.user.admin?

      # Or with Devise
      # redirect_to "/", alert: "Not authorized." unless current_user&.admin?
    end

    private

    def set_current_space
      return unless respond_to?(:current_user) && current_user

      space = find_current_space
      set_current_tenant(space) if space
    end

    def find_current_space
      if session[:current_space_id]
        current_user.spaces.active.find_by(id: session[:current_space_id])
      else
        current_user.active_spaces.first
      end
    end

    def current_space
      ActsAsTenant.current_tenant
    end
    helper_method :current_space
  end
end
