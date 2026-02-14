# frozen_string_literal: true

module Madmin
  class ExpensesController < Madmin::ResourceController
    def index
      @records = resource.model.where(user: current_user)

      # Filter by recurrence type
      @records = @records.where(recurrence_type: params[:recurrence_type]) if params[:recurrence_type].present?

      # Filter by date range
      @records = @records.where(expense_date: (params[:start_date])..) if params[:start_date].present?
      @records = @records.where(expense_date: ..(params[:end_date])) if params[:end_date].present?

      # Filter by tag
      if params[:tag_id].present?
        @records = @records.joins(:tags).where(tags: {id: params[:tag_id]})
      end

      # Order by most recent first
      @records = @records.order(expense_date: :desc, created_at: :desc)

      # Apply eager loading for performance
      @records = @records.includes(:tags)

      # Use pagination
      @pagy, @records = pagy(@records, items: 25)
    end

    def new
      @record = resource.model.new(
        user: current_user,
        expense_date: Date.current,
        recurrence_type: "one_time"
      )
    end

    def create
      @record = resource.model.new(expense_params.except(:tag_list))
      @record.user = current_user

      if @record.save
        handle_tags(@record, params[:expense][:tag_list])
        redirect_to resource.show_path(@record),
          notice: "Expense was successfully created."
      else
        render :new, status: :unprocessable_content
      end
    end

    def update
      @record = resource.model.find(params[:id])

      if @record.update(expense_params.except(:tag_list))
        handle_tags(@record, params[:expense][:tag_list])
        redirect_to resource.show_path(@record),
          notice: "Expense was successfully updated."
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @expense = Expense.where(user: current_user).find(params[:id])
      @expense.destroy
      redirect_to madmin_expenses_path, notice: "Expense was successfully deleted."
    end

    private

    def expense_params
      params.expect(expense: [:title, :description, :amount, :expense_date, :recurrence_type, :tag_list])
    end

    def handle_tags(expense, tag_list_string)
      # If the tag_list param wasn't submitted at all, don't modify tags
      return if tag_list_string.nil?

      # If the field was submitted but left empty, clear all tags
      cleaned = tag_list_string.to_s.split(",").map(&:strip).compact_blank
      if cleaned.empty?
        expense.tags = []
        return
      end

      tags = cleaned.map { |name| current_user.tags.find_or_create_by(name: name) }
      expense.tags = tags
    end
  end
end
