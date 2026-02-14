# frozen_string_literal: true

# == Schema Information
#
# Table name: spaces
#
#  id          :bigint           not null, primary key
#  description :text
#  name        :string           not null
#  settings    :jsonb
#  status      :string           default("active"), not null
#  uuid        :uuid             not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_spaces_on_name    (name)
#  index_spaces_on_status  (status)
#  index_spaces_on_uuid    (uuid) UNIQUE
#
class Space < ApplicationRecord
  # Constants
  STATUSES = %w[active suspended inactive].freeze

  # Callbacks
  before_validation :ensure_uuid
  validate :must_have_one_active_space_per_user, on: :update

  # Associations
  has_many :space_memberships, dependent: :destroy
  has_many :users, through: :space_memberships
  has_many :firms, dependent: :destroy
  has_many :accounts, dependent: :destroy
  has_many :trades, dependent: :destroy
  has_many :expenses, dependent: :destroy
  has_many :rules, dependent: :destroy
  has_many :tags, dependent: :destroy

  # Validations
  validates :name, presence: true
  validates :status, presence: true, inclusion: {in: STATUSES}
  validates :uuid, uniqueness: true

  # Scopes
  scope :active, -> { where(status: "active") }

  # Instance methods
  def to_s
    "##{id} - #{name}"
  end

  def can_be_archived?
    return true if status != "active" # Already inactive

    # Check if any user would lose their last active space
    users.each do |user|
      active_count = user.spaces.active.count
      # If this is being changed from active to inactive, subtract 1
      active_count -= 1 if status_was == "active" && status == "inactive"

      return false if active_count < 1
    end

    true
  end

  private

  def ensure_uuid
    self.uuid ||= SecureRandom.uuid
  end

  def must_have_one_active_space_per_user
    return unless status_changed? && status == "inactive"

    users.each do |user|
      other_active_spaces = user.spaces.active.where.not(id: id).count
      if other_active_spaces.zero?
        errors.add(:status, "cannot be inactive - user #{user.email} must have at least one active space")
      end
    end
  end
end
