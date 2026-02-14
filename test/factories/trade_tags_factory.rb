# frozen_string_literal: true

# == Schema Information
#
# Table name: trade_tags
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  space_id   :bigint           not null
#  tag_id     :bigint           not null
#  trade_id   :bigint           not null
#
# Indexes
#
#  index_trade_tags_on_space_id             (space_id)
#  index_trade_tags_on_tag_id               (tag_id)
#  index_trade_tags_on_trade_id             (trade_id)
#  index_trade_tags_on_trade_id_and_tag_id  (trade_id,tag_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (space_id => spaces.id)
#  fk_rails_...  (tag_id => tags.id)
#  fk_rails_...  (trade_id => trades.id)
#
FactoryBot.define do
  factory :trade_tag do
    trade
    tag
    transient do
      space { nil }
    end

    after(:build) do |trade_tag, evaluator|
      trade_tag.space ||= evaluator.space || trade_tag.trade&.space || trade_tag.tag&.space
    end
  end
end
