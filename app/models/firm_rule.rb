# frozen_string_literal: true

# == Schema Information
#
# Table name: firm_rules
#
#  id         :bigint           not null, primary key
#  end_date   :date
#  is_active  :boolean          default(TRUE), not null
#  notes      :text
#  rule_value :string           not null
#  start_date :date             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  firm_id    :bigint           not null
#  rule_id    :bigint           not null
#  space_id   :bigint           not null
#
# Indexes
#
#  idx_firm_rules_no_overlap_active            (firm_id,rule_id) UNIQUE WHERE (end_date IS NULL)
#  idx_firm_rules_unique_period                (firm_id,rule_id,start_date)
#  index_firm_rules_on_end_date                (end_date)
#  index_firm_rules_on_firm_id                 (firm_id)
#  index_firm_rules_on_firm_id_and_is_active   (firm_id,is_active)
#  index_firm_rules_on_rule_id                 (rule_id)
#  index_firm_rules_on_rule_id_and_start_date  (rule_id,start_date)
#  index_firm_rules_on_space_id                (space_id)
#
# Foreign Keys
#
#  fk_rails_...  (firm_id => firms.id)
#  fk_rails_...  (rule_id => rules.id)
#  fk_rails_...  (space_id => spaces.id)
#
class FirmRule < ApplicationRecord
  acts_as_tenant :space

  # Associations
  belongs_to :firm
  belongs_to :rule

  # Callbacks
  before_validation :set_space_from_associations

  # Validations
  validates :rule_value, presence: true
  validates :start_date, presence: true
  validate :end_date_after_start_date
  validate :no_overlapping_periods

  # Scopes
  scope :active, -> { where(is_active: true) }
  scope :current,
    lambda { |date = Date.current|
      where("start_date <= ? AND (end_date IS NULL OR end_date > ?)", date, date)
    }

  private

  def end_date_after_start_date
    return unless end_date.present? && start_date.present?

    errors.add(:end_date, "must be after start date") if end_date <= start_date
  end

  def no_overlapping_periods
    return unless firm && rule && start_date

    overlapping = firm.firm_rules
      .where(rule: rule)
      .where.not(id: id)
      .where("start_date < ? AND (end_date IS NULL OR end_date > ?)",
        end_date,
        start_date)

    errors.add(:start_date, "overlaps with existing rule period") if overlapping.exists?
  end

  def set_space_from_associations
    self.space ||= firm&.space || rule&.space
  end
end
