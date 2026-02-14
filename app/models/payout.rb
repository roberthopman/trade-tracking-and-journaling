# frozen_string_literal: true

# == Schema Information
#
# Table name: payouts
#
#  id               :bigint           not null, primary key
#  amount_paid      :decimal(15, 2)
#  amount_requested :decimal(15, 2)   not null
#  notes            :text
#  payout_number    :integer
#  received_date    :date
#  request_status   :string           default("pending"), not null
#  requested_date   :date             not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  account_id       :bigint           not null
#  space_id         :bigint           not null
#
# Indexes
#
#  index_payouts_on_account_id                    (account_id)
#  index_payouts_on_account_id_and_payout_number  (account_id,payout_number)
#  index_payouts_on_request_status                (request_status)
#  index_payouts_on_requested_date                (requested_date)
#  index_payouts_on_space_id                      (space_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (space_id => spaces.id)
#
class Payout < ApplicationRecord
  acts_as_tenant :space

  REQUEST_STATUSES = %w[pending approved declined].freeze

  belongs_to :account
  belongs_to :space

  validates :requested_date, presence: true
  validates :amount_requested, presence: true, numericality: {greater_than: 0}
  validates :amount_paid, numericality: {greater_than: 0}, allow_nil: true
  validates :request_status, presence: true, inclusion: {in: REQUEST_STATUSES}
  validate :amount_paid_does_not_exceed_available_balance, if: -> { approved? && amount_paid.present? }

  before_validation :set_default_dates, on: :create
  before_create :set_payout_number

  scope :pending, -> { where(request_status: "pending") }
  scope :approved, -> { where(request_status: "approved") }
  scope :declined, -> { where(request_status: "declined") }
  scope :for_account, ->(account) { where(account: account) }
  scope :recent, -> { order(requested_date: :desc) }

  def account_status
    account.status
  end

  def account_identifier
    account.to_s
  end

  def fully_paid?
    amount_paid.present? && amount_paid == amount_requested
  end

  def days_to_receive
    return nil unless requested_date && received_date

    (received_date - requested_date).to_i
  end

  def approved?
    request_status == "approved"
  end

  def declined?
    request_status == "declined"
  end

  def pending?
    request_status == "pending"
  end

  private

  def set_payout_number
    self.payout_number ||= account.payouts.maximum(:payout_number).to_i + 1
  end

  def set_default_dates
    self.requested_date ||= Date.current
  end

  def amount_paid_does_not_exceed_available_balance
    return unless account

    # Calculate available balance excluding this payout to avoid circular reference
    other_payouts_total = account.payouts.approved.where.not(id: id).where.not(amount_paid: nil).sum(:amount_paid)
    available_balance = account.initial_balance + account.trades_sum_pnl - other_payouts_total

    if amount_paid > available_balance
      errors.add(:amount_paid, "cannot exceed available balance of #{ActionController::Base.helpers.number_to_currency(available_balance)}")
    end
  end
end
