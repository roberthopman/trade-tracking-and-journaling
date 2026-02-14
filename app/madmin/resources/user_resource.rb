# frozen_string_literal: true

class UserResource < Madmin::Resource
  # Attributes
  attribute :id, form: false
  # Index/Table Attributes (most important first)
  attribute :email, index: true
  attribute :first_name, index: true
  attribute :last_name, index: true

  # Additional attributes for forms and detail view
  attribute :sign_in_count, form: false
  attribute :encrypted_password
  attribute :reset_password_token
  attribute :reset_password_sent_at
  attribute :remember_created_at
  attribute :updated_at, form: false
  attribute :uuid
  attribute :current_sign_in_at
  attribute :current_sign_in_ip
  attribute :last_sign_in_ip
  attribute :confirmation_token
  attribute :confirmed_at
  attribute :confirmation_sent_at
  attribute :unconfirmed_email
  attribute :timezone
  attribute :status
  attribute :date_of_birth
  attribute :country_code
  attribute :preferences

  # Associations
  attribute :accounts
  attribute :firms

  # Add scopes to easily filter records
  # scope :published

  # Add actions to the resource's show page
  member_action do |record|
    link_to "Impersonate User",
      impersonate_user_path(record),
      method: :post,
      data: {"turbo-method": :post},
      class: "bg-yellow-500 hover:bg-yellow-600 text-white font-semibold py-2 px-4 rounded-lg transition-colors"
  end

  # Customize the display name of records in the admin area.
  def self.display_name(record) = record.to_s

  # Customize the default sort column and direction.
  # def self.default_sort_column = "created_at"
  #
  # def self.default_sort_direction = "desc"
end
