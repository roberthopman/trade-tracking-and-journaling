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
class Tag < ApplicationRecord
  acts_as_tenant :space

  belongs_to :space
  belongs_to :user
  has_many :trade_tags, dependent: :destroy
  has_many :trades, through: :trade_tags
  has_many :expense_tags, dependent: :destroy
  has_many :expenses, through: :expense_tags

  validates :name, presence: true, uniqueness: {scope: :space_id}
  validates :color, presence: true

  scope :for_user, ->(user) { where(user: user) }

  def to_s
    name
  end
end
