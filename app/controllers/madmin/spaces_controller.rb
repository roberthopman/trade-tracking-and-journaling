# frozen_string_literal: true

module Madmin
  class SpacesController < Madmin::ResourceController
    def index
      # Only show spaces the current user belongs to
      @records = current_user.spaces
      @records = @records.order(created_at: :desc)
      @pagy, @records = pagy(@records, items: 25)
    end
  end
end
