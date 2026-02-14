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
FactoryBot.define do
  factory :firm do
    space

    sequence(:name) { |n| "Test Trading Firm #{n}" }
    status { "active" }
    legal_name { "Test Trading Legal #{name}" }
    country_code { "US" }
    website_url { "https://example.com" }
    description { "Professional prop trading firm" }

    trait :inactive do
      status { "inactive" }
    end

    trait :suspended do
      status { "suspended" }
    end
  end
end
