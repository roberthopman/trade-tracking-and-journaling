# frozen_string_literal: true

module Account::PayoutCalculations
  extend ActiveSupport::Concern

  # Count of approved payouts
  def total_payouts_count
    payouts.approved.count
  end

  # Total amount withdrawn from account (only approved payouts with amount_paid)
  def total_amount_withdrawn
    payouts.approved.where.not(amount_paid: nil).sum(:amount_paid)
  end

  # Most recent approved payout
  def last_payout
    payouts.approved.order(received_date: :desc, requested_date: :desc).first
  end

  # Date of last payout
  def last_payout_date
    last_payout&.received_date || last_payout&.requested_date
  end
end
