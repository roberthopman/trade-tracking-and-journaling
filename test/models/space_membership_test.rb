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
require "test_helper"

class SpaceMembershipTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
