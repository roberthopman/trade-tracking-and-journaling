# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Pretender - allows admins to impersonate users
  impersonates :user

  # Multi-tenancy
  set_current_tenant_through_filter
  before_action :authenticate_user!
  before_action :set_current_space

  private

  def set_current_space
    return unless user_signed_in?

    space = find_current_space
    if space
      set_current_tenant(space)
      session[:current_space_id] = space.id
    else
      # User has no spaces yet - redirect to create one
      redirect_to_space_creation_if_needed
    end
  end

  def find_current_space
    # Clear session space if impersonating and it doesn't belong to impersonated user
    if current_user != true_user && session[:current_space_id]
      space = current_user.spaces.active.find_by(id: session[:current_space_id])
      session[:current_space_id] = nil unless space
    end

    # Priority: session > first active space
    if session[:current_space_id]
      current_user.spaces.active.find_by(id: session[:current_space_id])
    else
      current_user.active_spaces.first
    end
  end

  def redirect_to_space_creation_if_needed
    # Skip redirect if already on space creation page
    return if controller_name == "spaces" && action_name.in?(%w[new create])

    # Redirect to create first space
    redirect_to new_space_path, alert: "Please create a space to get started"
  end

  def current_space
    ActsAsTenant.current_tenant
  end
  helper_method :current_space
end
