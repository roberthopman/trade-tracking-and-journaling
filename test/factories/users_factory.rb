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
FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    password_confirmation { "password123" }
    first_name { "Test" }
    last_name { "User" }
    status { "active" }
    confirmed_at { Time.current }

    # Automatically create a space membership for the user
    after(:create) do |user|
      create(:space_membership, user: user) unless user.space_memberships.exists?
    end

    trait :unconfirmed do
      confirmed_at { nil }
    end

    trait :suspended do
      status { "suspended" }
    end
  end
end
