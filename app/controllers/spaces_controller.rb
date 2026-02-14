# frozen_string_literal: true

class SpacesController < ApplicationController
  skip_before_action :set_current_space, only: [:new, :create]
  before_action :set_space, only: [:edit, :update, :switch, :archive, :activate]

  def index
    @active_spaces = current_user.spaces.active
    @inactive_spaces = current_user.spaces.where(status: "inactive")
  end

  def new
    @space = Space.new
  end

  def edit
    authorize_space_management!
  end

  def create
    @space = Space.new(space_params)

    if @space.save
      # Create membership for the creator as owner
      @space.space_memberships.create!(
        user: current_user,
        role: "owner",
        status: "active"
      )

      session[:current_space_id] = @space.id
      redirect_to authenticated_root_path, notice: "Space created successfully"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize_space_management!

    if @space.update(space_params)
      redirect_to spaces_path, notice: "Space updated successfully"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def switch
    membership = current_user.space_memberships.active.find_by(space: @space)
    if membership
      session[:current_space_id] = @space.id
      redirect_to authenticated_root_path, notice: "Switched to #{@space.name}"
    else
      redirect_to spaces_path, alert: "You don't have access to that space"
    end
  end

  def archive
    authorize_space_management!

    # Prevent archiving the last active space
    if current_user.active_spaces.one?
      redirect_to spaces_path, alert: "Cannot archive your last active space. You must have at least one active space."
      return
    end

    if @space.update(status: "inactive")
      # If archiving current space, switch to another active space
      if current_space == @space
        new_space = current_user.active_spaces.where.not(id: @space.id).first
        session[:current_space_id] = new_space&.id
      end

      redirect_to spaces_path, notice: "Space archived successfully"
    else
      redirect_to spaces_path, alert: "Failed to archive space"
    end
  end

  def activate
    authorize_space_management!

    if @space.update(status: "active")
      redirect_to spaces_path, notice: "Space activated successfully"
    else
      redirect_to spaces_path, alert: "Failed to activate space"
    end
  end

  private

  def set_space
    # Allow finding inactive spaces for archive/activate actions
    @space = current_user.spaces.find(params[:id])
  end

  def space_params
    params.expect(space: [:name, :description, :status])
  end

  def authorize_space_management!
    membership = current_user.membership_in(@space)
    unless membership&.can_manage?
      redirect_to spaces_path, alert: "You don't have permission to manage this space"
    end
  end
end
