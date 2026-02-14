# frozen_string_literal: true

# == Schema Information
#
# Table name: expenses
#
#  id              :bigint           not null, primary key
#  amount          :decimal(15, 2)   not null
#  description     :text
#  expense_date    :date             not null
#  recurrence_type :string           default("one_time"), not null
#  title           :string           not null
#  uuid            :uuid             not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  space_id        :bigint           not null
#  user_id         :bigint           not null
#
# Indexes
#
#  index_expenses_on_recurrence_type           (recurrence_type)
#  index_expenses_on_space_id                  (space_id)
#  index_expenses_on_user_id                   (user_id)
#  index_expenses_on_user_id_and_expense_date  (user_id,expense_date)
#  index_expenses_on_uuid                      (uuid) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (space_id => spaces.id)
#  fk_rails_...  (user_id => users.id)
#
class Expense < ApplicationRecord
  acts_as_tenant :space

  # Constants
  RECURRENCE_TYPES = %w[one_time weekly biweekly monthly quarterly yearly].freeze

  # Callbacks
  before_validation :ensure_uuid

  # Associations
  belongs_to :space
  belongs_to :user
  has_many :expense_tags, dependent: :destroy
  has_many :tags, through: :expense_tags

  # Validations
  validates :title, presence: true
  validates :amount, presence: true, numericality: {greater_than: 0}
  validates :expense_date, presence: true
  validates :recurrence_type, presence: true, inclusion: {in: RECURRENCE_TYPES}
  validates :uuid, uniqueness: true

  # Scopes
  scope :one_time, -> { where(recurrence_type: "one_time") }
  scope :recurring, -> { where.not(recurrence_type: "one_time") }
  scope :for_month, ->(date) { where(expense_date: date.all_month) }

  # Instance methods
  def recurring?
    recurrence_type != "one_time"
  end

  def to_s
    "#{title} - #{ActionController::Base.helpers.number_to_currency(amount)}"
  end

  def next_expense_date
    return nil unless recurring?

    today = Date.current
    return nil if expense_date > today

    case recurrence_type
    when "weekly"
      calculate_next_occurrence(expense_date, today, 1.week)
    when "biweekly"
      calculate_next_occurrence(expense_date, today, 2.weeks)
    when "monthly"
      calculate_next_occurrence(expense_date, today, 1.month)
    when "quarterly"
      calculate_next_occurrence(expense_date, today, 3.months)
    when "yearly"
      calculate_next_occurrence(expense_date, today, 1.year)
    end
  end

  private

  def calculate_next_occurrence(start_date, from_date, interval)
    next_date = start_date
    next_date += interval while next_date <= from_date
    next_date
  end

  def ensure_uuid
    self.uuid ||= SecureRandom.uuid
  end
end
