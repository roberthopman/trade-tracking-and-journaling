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
require "test_helper"

class TradeTagTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
