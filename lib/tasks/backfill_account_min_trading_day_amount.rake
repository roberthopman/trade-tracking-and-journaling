# frozen_string_literal: true

namespace :data do
  desc "Backfill Min Trading Day Amount ($) rule to all existing non-template accounts"
  task backfill_account_min_trading_day_amount: :environment do
    puts "🔄 Backfilling 'Min Trading Day Amount ($)' to all non-template accounts..."
    puts "=" * 80

    accounts_updated = 0
    accounts_skipped = 0
    accounts_total = 0

    Space.find_each do |space|
      ActsAsTenant.with_tenant(space) do
        rule = Rule.find_by(name: "Min Trading Day Amount ($)")

        unless rule
          puts "   ⚠️  Space #{space.id} (#{space.name}): Rule not found, skipping space"
          next
        end

        non_template_accounts = Account.where(template: false)
        accounts_total += non_template_accounts.count

        non_template_accounts.find_each do |account|
          existing_account_rule = account.account_rules.find_by(rule_id: rule.id)

          if existing_account_rule
            accounts_skipped += 1
          else
            account.account_rules.create!(
              rule: rule,
              rule_value: "100",
              start_date: account.start_date || Date.current
            )
            puts "   ✓ Account #{account.id} (#{account.name}): Added rule with value $100"
            accounts_updated += 1
          end
        end
      end
    end

    puts "=" * 80
    puts "✅ Backfill complete!"
    puts "   Accounts updated: #{accounts_updated}"
    puts "   Accounts skipped: #{accounts_skipped}"
    puts "   Total non-template accounts: #{accounts_total}"
  end
end
