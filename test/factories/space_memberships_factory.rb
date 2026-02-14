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
FactoryBot.define do
  factory :space_membership do
    user
    space
    role { "member" }
    status { "active" }

    trait :owner do
      role { "owner" }
    end

    trait :admin do
      role { "admin" }
    end

    trait :viewer do
      role { "viewer" }
    end

    trait :suspended do
      status { "suspended" }
    end
  end
end
