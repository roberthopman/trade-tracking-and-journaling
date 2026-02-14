# frozen_string_literal: true

# == Schema Information
#
# Table name: account_rules
#
#  id                 :bigint           not null, primary key
#  end_date           :date
#  is_active          :boolean          default(TRUE), not null
#  is_custom_override :boolean          default(FALSE), not null
#  is_inherited       :boolean          default(TRUE), not null
#  notes              :text
#  rule_value         :string           not null
#  start_date         :date             not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  account_id         :bigint           not null
#  rule_id            :bigint           not null
#  space_id           :bigint           not null
#
# Indexes
#
#  idx_account_rules_no_overlap_active              (account_id,rule_id) UNIQUE WHERE (end_date IS NULL)
#  idx_account_rules_unique_period                  (account_id,rule_id,start_date)
#  index_account_rules_on_account_id                (account_id)
#  index_account_rules_on_account_id_and_is_active  (account_id,is_active)
#  index_account_rules_on_is_custom_override        (is_custom_override)
#  index_account_rules_on_is_inherited              (is_inherited)
#  index_account_rules_on_rule_id                   (rule_id)
#  index_account_rules_on_rule_id_and_start_date    (rule_id,start_date)
#  index_account_rules_on_space_id                  (space_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (rule_id => rules.id)
#  fk_rails_...  (space_id => spaces.id)
#
class AccountRule < ApplicationRecord
  acts_as_tenant :space

  # Associations
  belongs_to :account
  belongs_to :rule

  # Callbacks
  before_validation :set_space_from_associations

  # Validations
  validates :rule_value, presence: true
  validates :start_date, presence: true
  validate :end_date_after_start_date
  validate :no_overlapping_periods
  validate :validate_rule_value_format

  # Scopes
  scope :active, -> { where(is_active: true) }
  scope :is_inherited, -> { where(is_inherited: true) }
  scope :custom, -> { where(is_custom_override: true) }
  scope :current,
    lambda { |date = Date.current|
      where("start_date <= ? AND (end_date IS NULL OR end_date > ?)", date, date)
    }

  # Instance methods
  def effective_value
    rule_value
  end

  private

  def end_date_after_start_date
    return unless end_date.present? && start_date.present?

    errors.add(:end_date, "must be after start date") if end_date <= start_date
  end

  def no_overlapping_periods
    return unless account && rule && start_date

    # Use far future date if end_date is nil
    effective_end_date = end_date || Date.new(9999, 12, 31)

    overlapping = account.account_rules
      .where(rule: rule)
      .where.not(id: id)
      .where("start_date < ? AND (end_date IS NULL OR end_date > ?)",
        effective_end_date,
        start_date)

    errors.add(:start_date, "overlaps with existing rule period") if overlapping.exists?
  end

  def validate_rule_value_format
    return unless rule && rule_value.present?

    case rule.data_type
    when "percentage"
      validate_percentage
    when "currency_amount"
      validate_currency_amount
    when "integer_count"
      validate_integer_count
    when "boolean_flag"
      validate_boolean
    end
  end

  def validate_percentage
    value = rule_value.to_f
    min = rule.validation_config["min"] || 0
    max = rule.validation_config["max"] || 100

    unless value.between?(min, max)
      errors.add(:rule_value, "must be between #{min} and #{max}")
    end
  end

  def validate_currency_amount
    value = rule_value.to_f
    min = rule.validation_config["min"] || 0

    unless value >= min
      errors.add(:rule_value, "must be at least #{min}")
    end
  end

  def validate_integer_count
    value = rule_value.to_i
    min = rule.validation_config["min"] || 0

    unless value >= min
      errors.add(:rule_value, "must be at least #{min}")
    end
  end

  def validate_boolean
    unless %w[true false 1 0].include?(rule_value.to_s.downcase)
      errors.add(:rule_value, "must be true or false")
    end
  end

  def set_space_from_associations
    self.space ||= account&.space || rule&.space
  end
end
