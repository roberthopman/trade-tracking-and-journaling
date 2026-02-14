# frozen_string_literal: true

namespace :data do
  desc "Backfill Min Trading Day Amount ($) rule to all existing spaces"
  task backfill_min_trading_day_amount: :environment do
    puts "🔄 Backfilling 'Min Trading Day Amount ($)' rule to all spaces..."
    puts "=" * 80

    rule_data = {
      name: "Min Trading Day Amount ($)",
      rule_type: "trading_behavior",
      data_type: "currency_amount",
      calculation_method: "simple_threshold",
      time_scope: "daily",
      validation_config: {min: 0},
      description: "Minimum dollar amount required for a day to count as a trading day",
      sort_order: 5
    }

    spaces_updated = 0
    spaces_skipped = 0

    Space.find_each do |space|
      ActsAsTenant.with_tenant(space) do
        existing_rule = Rule.find_by(name: rule_data[:name])

        if existing_rule
          puts "   ⚠️  Space #{space.id} (#{space.name}): Rule already exists, skipping"
          spaces_skipped += 1
        else
          rule = Rule.create!(
            name: rule_data[:name],
            rule_type: rule_data[:rule_type],
            data_type: rule_data[:data_type],
            calculation_method: rule_data[:calculation_method],
            time_scope: rule_data[:time_scope],
            validation_config: rule_data[:validation_config],
            description: rule_data[:description],
            sort_order: rule_data[:sort_order],
            is_active: true,
            violation_action: "hard_breach"
          )
          puts "   ✓ Space #{space.id} (#{space.name}): Created rule (ID: #{rule.id})"
          spaces_updated += 1
        end
      end
    end

    puts "=" * 80
    puts "✅ Backfill complete!"
    puts "   Spaces updated: #{spaces_updated}"
    puts "   Spaces skipped: #{spaces_skipped}" if spaces_skipped > 0
    puts "   Total spaces: #{Space.count}"
  end
end
