# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  admin                  :boolean          default(FALSE), not null
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  country_code           :string(2)
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string
#  date_of_birth          :date
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  first_name             :string
#  last_name              :string
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :string
#  preferences            :jsonb
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  sign_in_count          :integer          default(0), not null
#  status                 :string           default("active"), not null
#  timezone               :string           default("UTC")
#  unconfirmed_email      :string
#  uuid                   :uuid             not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_confirmation_token        (confirmation_token) UNIQUE
#  index_users_on_email                     (email) UNIQUE
#  index_users_on_last_name_and_first_name  (last_name,first_name)
#  index_users_on_preferences               (preferences) USING gin
#  index_users_on_reset_password_token      (reset_password_token) UNIQUE
#  index_users_on_status                    (status)
#  index_users_on_uuid                      (uuid) UNIQUE
#
class User < ApplicationRecord
  devise :database_authenticatable,
    :registerable,
    :recoverable,
    :rememberable,
    :validatable,
    :confirmable,
    :trackable

  # Constants
  STATUSES = %w[active suspended inactive].freeze

  # Associations
  has_many :space_memberships, dependent: :destroy
  has_many :spaces, through: :space_memberships
  has_many :accounts, dependent: :destroy
  has_many :firms, through: :accounts
  has_many :tags, dependent: :destroy
  has_many :expenses, dependent: :destroy

  # Validations
  validates :status, presence: true, inclusion: {in: STATUSES}
  validates :timezone, presence: true
  validates :country_code, length: {is: 2}, allow_blank: true

  # Scopes
  scope :active, -> { where(status: "active") }
  scope :by_country, ->(code) { where(country_code: code) }

  # Instance methods
  def full_name
    [first_name, last_name].compact.join(" ")
  end

  def display_name
    full_name.presence || email
  end

  def preferences_for(key)
    preferences&.dig(key) || {}
  end

  def active_accounts
    accounts.where(status: "active")
  end

  def real_accounts
    accounts.where(template: false)
  end

  def active_spaces
    spaces.where(space_memberships: {status: "active"})
  end

  def membership_in(space)
    space_memberships.find_by(space: space)
  end

  def to_s
    "##{id} - #{email}"
  end
end
