# frozen_string_literal: true

# == Schema Information
#
# Table name: rules
#
#  id                 :bigint           not null, primary key
#  calculation_method :string           default("simple_threshold"), not null
#  data_type          :string           not null
#  description        :text
#  is_active          :boolean          default(TRUE), not null
#  name               :string           not null
#  rule_type          :string           not null
#  sort_order         :integer          default(0)
#  time_scope         :string           default("daily"), not null
#  validation_config  :jsonb
#  violation_action   :string           default("hard_breach"), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  space_id           :bigint           not null
#
# Indexes
#
#  index_rules_on_calculation_method  (calculation_method)
#  index_rules_on_is_active           (is_active)
#  index_rules_on_rule_type           (rule_type)
#  index_rules_on_space_id            (space_id)
#  index_rules_on_space_id_and_name   (space_id,name) UNIQUE
#  index_rules_on_time_scope          (time_scope)
#  index_rules_on_validation_config   (validation_config) USING gin
#  index_rules_on_violation_action    (violation_action)
#
# Foreign Keys
#
#  fk_rails_...  (space_id => spaces.id)
#
FactoryBot.define do
  factory :rule do
    space

    sequence(:name) { |n| "Test Rule #{n}" }
    description { "Test rule description" }
    rule_type { "risk_management" }
    data_type { "percentage" }
    calculation_method { "simple_threshold" }
    time_scope { "daily" }
    violation_action { "hard_breach" }
    validation_config { {min: 0, max: 100} }
    is_active { true }
    sort_order { 0 }
  end
end
