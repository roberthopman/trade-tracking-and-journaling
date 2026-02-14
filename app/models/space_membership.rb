# frozen_string_literal: true

# == Schema Information
#
# Table name: space_memberships
#
#  id         :bigint           not null, primary key
#  role       :string           default("member"), not null
#  status     :string           default("active"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  space_id   :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_space_memberships_on_space_id              (space_id)
#  index_space_memberships_on_space_id_and_role     (space_id,role)
#  index_space_memberships_on_user_id               (user_id)
#  index_space_memberships_on_user_id_and_space_id  (user_id,space_id) UNIQUE
#  index_space_memberships_on_user_id_and_status    (user_id,status)
#
# Foreign Keys
#
#  fk_rails_...  (space_id => spaces.id)
#  fk_rails_...  (user_id => users.id)
#
class SpaceMembership < ApplicationRecord
  # Constants
  ROLES = %w[owner admin member viewer].freeze
  STATUSES = %w[active suspended inactive].freeze

  # Associations
  belongs_to :user
  belongs_to :space

  # Validations
  validates :role, presence: true, inclusion: {in: ROLES}
  validates :status, presence: true, inclusion: {in: STATUSES}
  validates :user_id, uniqueness: {scope: :space_id}

  # Scopes
  scope :active, -> { where(status: "active") }
  scope :owners, -> { where(role: "owner") }
  scope :admins, -> { where(role: "admin") }

  # Instance methods
  def owner?
    role == "owner"
  end

  def admin?
    role == "admin"
  end

  def can_manage?
    owner? || admin?
  end
end
