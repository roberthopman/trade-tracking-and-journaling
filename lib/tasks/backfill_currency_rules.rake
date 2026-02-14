# frozen_string_literal: true

namespace :data do
  desc "Backfill 'Safety Net ($)' and 'Profit Target ($)' rules to all existing spaces"
  task backfill_currency_rules: :environment do
    puts "🔄 Backfilling currency-based rules to all spaces..."
    puts "=" * 80

    rules_data = [
      {
        name: "Safety Net ($)",
        rule_type: "risk_management",
        data_type: "currency_amount",
        calculation_method: "simple_threshold",
        time_scope: "daily",
        validation_config: {min: 0},
        description: "Protection buffer for account in dollars",
        sort_order: 13
      },
      {
        name: "Profit Target ($)",
        rule_type: "payout_eligibility",
        data_type: "currency_amount",
        calculation_method: "simple_threshold",
        time_scope: "lifetime",
        validation_config: {min: 0},
        description: "Initial profit target to reach in dollars",
        sort_order: 14
      }
    ]

    spaces_updated = 0
    spaces_skipped = 0
    rules_created = 0

    Space.find_each do |space|
      ActsAsTenant.with_tenant(space) do
        space_rules_created = 0

        rules_data.each do |rule_data|
          existing_rule = Rule.find_by(name: rule_data[:name])

          if existing_rule
            puts "   ⚠️  Space #{space.id} (#{space.name}): '#{rule_data[:name]}' already exists, skipping"
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
            puts "   ✓ Space #{space.id} (#{space.name}): Created '#{rule_data[:name]}' (ID: #{rule.id})"
            space_rules_created += 1
            rules_created += 1
          end
        end

        if space_rules_created > 0
          spaces_updated += 1
        else
          spaces_skipped += 1
        end
      end
    end

    puts "=" * 80
    puts "✅ Backfill complete!"
    puts "   Total rules created: #{rules_created}"
    puts "   Spaces updated: #{spaces_updated}"
    puts "   Spaces skipped (all rules existed): #{spaces_skipped}" if spaces_skipped > 0
    puts "   Total spaces: #{Space.count}"
  end
end
