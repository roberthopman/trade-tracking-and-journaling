# frozen_string_literal: true

# == Schema Information
#
# Table name: firms
#
#  id            :bigint           not null, primary key
#  contact_info  :text
#  country_code  :string(2)
#  description   :string
#  founding_date :date
#  legal_name    :string
#  metadata      :text
#  name          :string           not null
#  status        :string           default("active"), not null
#  website_url   :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  space_id      :bigint           not null
#
# Indexes
#
#  index_firms_on_country_code       (country_code)
#  index_firms_on_space_id           (space_id)
#  index_firms_on_space_id_and_name  (space_id,name) UNIQUE
#  index_firms_on_status             (status)
#
# Foreign Keys
#
#  fk_rails_...  (space_id => spaces.id)
#
class Firm < ApplicationRecord
  acts_as_tenant :space

  # Constants
  STATUSES = %w[active inactive suspended].freeze

  # Associations
  belongs_to :space
  has_many :firm_rules, dependent: :destroy
  has_many :rules, through: :firm_rules
  has_many :accounts, dependent: :destroy
  has_many :account_types,
    -> { where(template: true) },
    class_name: "Account",
    inverse_of: :firm,
    dependent: :destroy
  has_many :users, through: :accounts

  # Validations
  validates :name, presence: true, uniqueness: {scope: :space_id}
  validates :status, presence: true, inclusion: {in: STATUSES}
  validates :country_code, length: {is: 2}, allow_blank: true

  # Scopes
  scope :active, -> { where(status: "active") }
  scope :by_country, ->(code) { where(country_code: code) }

  # Instance methods
  def active_rules(date = Date.current)
    firm_rules.active.where("start_date <= ? AND (end_date IS NULL OR end_date > ?)", date, date)
  end

  def contact_info_parsed
    return {} if contact_info.blank?

    JSON.parse(contact_info)
  rescue JSON::ParserError
    {}
  end

  def to_s
    "##{id} - #{name}"
  end
end
