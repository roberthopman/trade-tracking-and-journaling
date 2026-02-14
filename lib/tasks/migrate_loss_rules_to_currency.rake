# frozen_string_literal: true

namespace :data do
  desc "Migrate percentage-based loss rules to dollar amounts"
  task migrate_loss_rules_to_currency: :environment do
    puts "🔄 Migrating loss rules from percentage to dollar amounts..."
    puts "=" * 80

    # Run without tenant context to update all spaces
    ActsAsTenant.without_tenant do
      migrate_daily_loss_limit
      migrate_max_total_loss
    end

    puts "=" * 80
    puts "✅ Migration complete!"
  end

  def migrate_daily_loss_limit
    puts "\n📊 Migrating 'Daily Loss Limit (%)' to 'Daily Loss Limit ($)'..."

    daily_loss_rules = Rule.where(name: "Daily Loss Limit (%)")

    if daily_loss_rules.empty?
      puts "   ⚠️  Rule 'Daily Loss Limit (%)' not found. Skipping."
      return
    end

    puts "   ✓ Found #{daily_loss_rules.count} rule(s) across spaces"

    total_migrated = 0
    total_skipped = 0

    daily_loss_rules.each do |daily_loss_rule|
      puts "\n   Processing Space #{daily_loss_rule.space_id} (Rule ID: #{daily_loss_rule.id})..."

      # Update the rule itself
      daily_loss_rule.update!(
        name: "Daily Loss Limit ($)",
        data_type: "currency_amount",
        validation_config: {min: 0},
        description: "Maximum dollar amount that can be lost in a single day"
      )
      puts "   ✓ Updated rule definition"

      # Update all associated account_rules
      account_rules = daily_loss_rule.account_rules.includes(:account)
      puts "   ✓ Found #{account_rules.count} account rules to migrate"

      migrated_count = 0
      skipped_count = 0

      account_rules.each do |account_rule|
        account = account_rule.account

        if account_rule.rule_value.blank?
          puts "   ⚠️  Skipping account rule #{account_rule.id} (no value)"
          skipped_count += 1
          next
        end

        if account.initial_balance.blank?
          puts "   ⚠️  Skipping account rule #{account_rule.id} (account has no initial_balance)"
          skipped_count += 1
          next
        end

        # Convert percentage to dollar amount
        percentage = account_rule.rule_value.to_f
        dollar_amount = (account.initial_balance * percentage / 100).round(2)

        account_rule.update!(rule_value: format("%.2f", dollar_amount))
        puts "   • Account #{account.id}: #{percentage}% → $#{format("%.2f", dollar_amount)}"
        migrated_count += 1
      end

      puts "   ✓ Migrated #{migrated_count} account rules in this space"
      puts "   ⚠️  Skipped #{skipped_count} account rules in this space" if skipped_count > 0

      total_migrated += migrated_count
      total_skipped += skipped_count
    end

    puts "\n   ═══════════════════════════════════════════════════════════"
    puts "   Total migrated: #{total_migrated} account rules"
    puts "   Total skipped: #{total_skipped} account rules" if total_skipped > 0
  end

  def migrate_max_total_loss
    puts "\n📊 Migrating 'Max Total Loss (%)' to 'Max Total Loss ($)'..."

    max_loss_rules = Rule.where(name: "Max Total Loss (%)")

    if max_loss_rules.empty?
      puts "   ⚠️  Rule 'Max Total Loss (%)' not found. Skipping."
      return
    end

    puts "   ✓ Found #{max_loss_rules.count} rule(s) across spaces"

    total_migrated = 0
    total_skipped = 0

    max_loss_rules.each do |max_loss_rule|
      puts "\n   Processing Space #{max_loss_rule.space_id} (Rule ID: #{max_loss_rule.id})..."

      # Update the rule itself
      max_loss_rule.update!(
        name: "Max Total Loss ($)",
        data_type: "currency_amount",
        validation_config: {min: 0},
        description: "Maximum dollar drawdown allowed on the account"
      )
      puts "   ✓ Updated rule definition"

      # Update all associated account_rules
      account_rules = max_loss_rule.account_rules.includes(:account)
      puts "   ✓ Found #{account_rules.count} account rules to migrate"

      migrated_count = 0
      skipped_count = 0

      account_rules.each do |account_rule|
        account = account_rule.account

        if account_rule.rule_value.blank?
          puts "   ⚠️  Skipping account rule #{account_rule.id} (no value)"
          skipped_count += 1
          next
        end

        if account.initial_balance.blank?
          puts "   ⚠️  Skipping account rule #{account_rule.id} (account has no initial_balance)"
          skipped_count += 1
          next
        end

        # Convert percentage to dollar amount
        percentage = account_rule.rule_value.to_f
        dollar_amount = (account.initial_balance * percentage / 100).round(2)

        account_rule.update!(rule_value: format("%.2f", dollar_amount))
        puts "   • Account #{account.id}: #{percentage}% → $#{format("%.2f", dollar_amount)}"
        migrated_count += 1
      end

      puts "   ✓ Migrated #{migrated_count} account rules in this space"
      puts "   ⚠️  Skipped #{skipped_count} account rules in this space" if skipped_count > 0

      total_migrated += migrated_count
      total_skipped += skipped_count
    end

    puts "\n   ═══════════════════════════════════════════════════════════"
    puts "   Total migrated: #{total_migrated} account rules"
    puts "   Total skipped: #{total_skipped} account rules" if total_skipped > 0
  end
end
