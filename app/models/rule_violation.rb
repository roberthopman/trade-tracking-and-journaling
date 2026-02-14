# frozen_string_literal: true

# == Schema Information
#
# Table name: rule_violations
#
#  id                  :bigint           not null, primary key
#  account_terminated  :boolean          default(FALSE), not null
#  action_taken        :string
#  actual_value        :decimal(15, 5)
#  comparison_operator :string
#  details             :text
#  detected_at         :datetime         not null
#  resolution_notes    :text
#  resolved_at         :datetime
#  resolved_by         :string
#  severity            :string           not null
#  status              :string           default("active"), not null
#  threshold_value     :decimal(15, 5)
#  violation_date      :date
#  violation_type      :string           not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  account_id          :bigint           not null
#  rule_id             :bigint           not null
#  space_id            :bigint           not null
#  trade_id            :bigint
#
# Indexes
#
#  index_rule_violations_on_account_id                     (account_id)
#  index_rule_violations_on_account_id_and_status          (account_id,status)
#  index_rule_violations_on_account_id_and_violation_date  (account_id,violation_date)
#  index_rule_violations_on_account_terminated             (account_terminated)
#  index_rule_violations_on_rule_id                        (rule_id)
#  index_rule_violations_on_rule_id_and_detected_at        (rule_id,detected_at)
#  index_rule_violations_on_severity                       (severity)
#  index_rule_violations_on_space_id                       (space_id)
#  index_rule_violations_on_trade_id                       (trade_id)
#  index_rule_violations_on_violation_date                 (violation_date)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (rule_id => rules.id)
#  fk_rails_...  (space_id => spaces.id)
#  fk_rails_...  (trade_id => trades.id)
#
class RuleViolation < ApplicationRecord
  acts_as_tenant :space

  # Constants
  STATUSES = %w[active resolved ignored].freeze
  SEVERITIES = %w[warning minor major critical].freeze

  # Associations
  belongs_to :account
  belongs_to :rule
  belongs_to :trade, optional: true

  # Callbacks
  before_validation :set_space_from_associations

  # Validations
  validates :violation_type, presence: true
  validates :status, presence: true, inclusion: {in: STATUSES}
  validates :severity, presence: true, inclusion: {in: SEVERITIES}
  validates :detected_at, presence: true
  validate :resolved_at_after_detected_at

  # Scopes
  scope :active, -> { where(status: "active") }
  scope :resolved, -> { where(status: "resolved") }
  scope :by_severity, ->(severity) { where(severity: severity) }
  scope :critical, -> { where(severity: "critical") }
  scope :recent, ->(days = 30) { where(detected_at: days.days.ago..) }

  # Instance methods
  def resolve!(resolved_by_user, notes = nil)
    update!(
      status: "resolved",
      resolved_at: Time.current,
      resolved_by: resolved_by_user,
      resolution_notes: notes
    )
  end

  def violation_percentage
    return nil unless threshold_value && actual_value && threshold_value != 0

    ((actual_value - threshold_value) / threshold_value * 100).round(2)
  end

  private

  def resolved_at_after_detected_at
    return unless resolved_at.present? && detected_at.present?

    errors.add(:resolved_at, "must be after detected at") if resolved_at <= detected_at
  end

  def set_space_from_associations
    self.space ||= account&.space || rule&.space || trade&.space
  end
end
