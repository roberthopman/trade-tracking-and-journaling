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
FactoryBot.define do
  factory :space do
    sequence(:name) { |n| "Test Space #{n}" }
    description { "A test workspace for prop trading" }
    status { "active" }
    settings { {} }

    trait :inactive do
      status { "inactive" }
    end

    trait :suspended do
      status { "suspended" }
    end
  end
end
