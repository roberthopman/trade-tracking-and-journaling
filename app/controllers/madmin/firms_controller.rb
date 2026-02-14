# frozen_string_literal: true

module Madmin
  class FirmsController < Madmin::ResourceController
    def index
      @firms = Firm.all

      # Apply status filter if present
      if params[:status].present? && Firm::STATUSES.include?(params[:status])
        @firms = @firms.where(status: params[:status])
      end

      # Apply name filter if present
      if params[:name].present?
        @firms = @firms.where("name ILIKE ?", "%#{params[:name]}%")
      end

      # Apply sorting (from Madmin)
      sort_column = params[:sort] || FirmResource.default_sort_column
      sort_direction = params[:direction] || FirmResource.default_sort_direction
      @firms = @firms.order("#{sort_column} #{sort_direction}")

      # Paginate using pagy
      @pagy, @records = pagy(@firms, items: 25)
    end

    def show
      @firm = Firm.find(params[:id])
    end
  end
end
