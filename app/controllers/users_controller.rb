# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin!

  def impersonate
    user = User.find(params[:id])
    impersonate_user(user)

    # Clear current space to force switching to impersonated user's space
    session[:current_space_id] = nil

    redirect_to madmin_dashboard_path, notice: "Now impersonating #{user.email}"
  end

  def stop_impersonating
    stop_impersonating_user

    # Clear current space to switch back to true user's space
    session[:current_space_id] = nil

    redirect_to madmin_users_path, notice: "Stopped impersonating"
  end

  private

  def authorize_admin!
    unless true_user&.admin?
      redirect_to after_sign_in_path_for(current_user), alert: "You must be an admin to impersonate users."
    end
  end
end
