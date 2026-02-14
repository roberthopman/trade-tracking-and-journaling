# frozen_string_literal: true

# == Schema Information
#
# Table name: tags
#
#  id         :bigint           not null, primary key
#  color      :string           default("#3B82F6")
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  space_id   :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_tags_on_space_id           (space_id)
#  index_tags_on_space_id_and_name  (space_id,name) UNIQUE
#  index_tags_on_user_id            (user_id)
#  index_tags_on_user_id_and_name   (user_id,name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (space_id => spaces.id)
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :tag do
    user
    transient do
      space { nil }
    end

    after(:build) do |tag, evaluator|
      tag.space ||= evaluator.space || tag.user&.spaces&.first || create(:space)
    end

    sequence(:name) { |n| "Test Tag #{n}" }
    color { "#3B82F6" }
  end
end
