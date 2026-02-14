# frozen_string_literal: true

# == Schema Information
#
# Table name: expense_tags
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  expense_id :bigint           not null
#  space_id   :bigint           not null
#  tag_id     :bigint           not null
#
# Indexes
#
#  index_expense_tags_on_expense_id             (expense_id)
#  index_expense_tags_on_expense_id_and_tag_id  (expense_id,tag_id) UNIQUE
#  index_expense_tags_on_space_id               (space_id)
#  index_expense_tags_on_tag_id                 (tag_id)
#
# Foreign Keys
#
#  fk_rails_...  (expense_id => expenses.id)
#  fk_rails_...  (space_id => spaces.id)
#  fk_rails_...  (tag_id => tags.id)
#
class ExpenseTag < ApplicationRecord
  acts_as_tenant :space

  belongs_to :expense
  belongs_to :tag

  validates :expense_id, uniqueness: {scope: :tag_id}

  before_validation :set_space_from_associations

  private

  def set_space_from_associations
    self.space ||= expense&.space || tag&.space
  end
end
