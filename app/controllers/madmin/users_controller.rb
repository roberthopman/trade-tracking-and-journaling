# frozen_string_literal: true

module Madmin
  class UsersController < Madmin::ResourceController
    before_action :authorize_admin!

    private

    def authorize_admin!
      unless current_user&.admin?
        redirect_to after_sign_in_path_for(current_user), alert: "You must be an admin to access user management."
      end
    end
  end
end
