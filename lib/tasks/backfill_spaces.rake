# frozen_string_literal: true

# This rake task provides the same functionality as the BackfillAndFinalizeSpaces migration
# It's useful for manual intervention or re-running after data changes

namespace :spaces do
  desc "Backfill spaces for existing users (same as migration 20251023142842)"
  task backfill: :environment do
    ActsAsTenant.without_tenant do
      puts "🔄 Starting space backfill for existing users..."

      users_processed = 0
      users_skipped = 0
      total_records = 0

      User.find_each do |user|
        if user.spaces.any?
          puts "  ⏭️  Skipping #{user.email} (already has #{user.spaces.count} space(s))"
          users_skipped += 1
          next
        end

        space = create_personal_space(user)
        records_assigned = assign_user_data_to_space(user, space)

        puts "  ✅ Created space for #{user.email} (#{records_assigned} records assigned)"
        users_processed += 1
        total_records += records_assigned
      end

      print_backfill_summary(users_processed, users_skipped, total_records)

      # Handle orphaned records
      fix_orphaned_records
    end
  end

  desc "Preview what would happen during backfill (dry run)"
  task preview: :environment do
    ActsAsTenant.without_tenant do
      puts "🔍 Preview: Space backfill for existing users"
      puts "=" * 60

      users_needing_spaces = User.includes(:spaces).select { |u| u.spaces.empty? }

      if users_needing_spaces.empty?
        puts "✅ All users already have spaces!"
        next
      end

      users_needing_spaces.each do |user|
        puts "\n📊 User: #{user.email}"
        puts "   Would create: \"Space-#{user.id}\""

        firm_count = user.accounts.includes(:firm).map(&:firm).uniq.count
        account_count = user.accounts.count
        trade_count = user.accounts.joins(:trades).count
        expense_count = user.expenses.count
        tag_count = user.tags.count

        puts "   Would assign:"
        puts "     - #{firm_count} firm(s)"
        puts "     - #{account_count} account(s)"
        puts "     - #{trade_count} trade(s)"
        puts "     - #{expense_count} expense(s)"
        puts "     - #{tag_count} tag(s)"
      end

      puts "\n" + ("=" * 60)
      puts "Total users needing spaces: #{users_needing_spaces.count}"
      puts "\nRun 'rake spaces:backfill' to execute the backfill"
    end
  end

  private

  def create_personal_space(user)
    Space.create!(
      name: "Space-#{user.id}",
      description: "Personal trading workspace for #{user.email}",
      status: "active",
      settings: {
        currency: "USD",
        timezone: user.timezone || "UTC",
        created_via_backfill: true
      }
    ).tap do |space|
      SpaceMembership.create!(
        user: user,
        space: space,
        role: "owner",
        status: "active"
      )
    end
  end

  def assign_user_data_to_space(user, space)
    count = 0

    # Firms
    user.accounts.includes(:firm).find_each do |account|
      if account.firm.space_id.nil?
        account.firm.update_column(:space_id, space.id)
        count += 1
      end
    end

    # Accounts
    count += user.accounts.where(space_id: nil).update_all(space_id: space.id)

    # Trades
    trade_ids = Trade.joins(:account).where(accounts: {user_id: user.id}, space_id: nil).pluck(:id)
    count += Trade.where(id: trade_ids).update_all(space_id: space.id)

    # Expenses
    count += user.expenses.where(space_id: nil).update_all(space_id: space.id)

    # Tags
    count += user.tags.where(space_id: nil).update_all(space_id: space.id)

    # Rules
    firm_ids = user.accounts.pluck(:firm_id).uniq
    rule_ids = FirmRule.where(firm_id: firm_ids).pluck(:rule_id).uniq
    count += Rule.where(id: rule_ids, space_id: nil).update_all(space_id: space.id)

    count
  end

  def print_backfill_summary(processed, skipped, total_records)
    puts "\n" + ("=" * 60)
    puts "🎉 Space backfill complete!"
    puts "=" * 60
    puts "📊 Summary:"
    puts "   Users processed: #{processed}"
    puts "   Users skipped: #{skipped}"
    puts "   Total records assigned: #{total_records}"
    puts "=" * 60
  end

  def fix_orphaned_records
    puts "\n🔧 Checking for orphaned records..."

    fix_orphaned_accounts
    fix_orphaned_account_rules
    fix_cross_space_references
    fix_orphaned_rules
    check_final_status
  end

  def fix_orphaned_accounts
    orphaned_accounts = Account.where(space_id: nil)
    return unless orphaned_accounts.any?

    puts "  Found #{orphaned_accounts.count} orphaned accounts (account types)"
    orphaned_accounts.each do |account|
      if account.firm&.space_id
        account.update_column(:space_id, account.firm.space_id)
        puts "    ✅ Fixed Account ##{account.id}"
      end
    end
  end

  def fix_orphaned_account_rules
    orphaned_account_rules = AccountRule.where(space_id: nil)
    return unless orphaned_account_rules.any?

    puts "  Found #{orphaned_account_rules.count} account_rules without space_id"
    orphaned_account_rules.each do |account_rule|
      if account_rule.account&.space_id
        account_rule.update_column(:space_id, account_rule.account.space_id)
        puts "    ✅ Fixed AccountRule ##{account_rule.id}"
      end
    end
  end

  def fix_cross_space_references
    puts "  🔧 Fixing account_rules cross-space references..."
    mismatched_rules = find_mismatched_rules

    if mismatched_rules.any?
      puts "    Found #{mismatched_rules.count} account_rules with cross-space references"
      fixed_count = fix_mismatched_rules(mismatched_rules)
      puts "    ✅ Fixed #{fixed_count} account_rules cross-space references"
    else
      puts "    ✅ No cross-space references found"
    end
  end

  def find_mismatched_rules
    AccountRule.joins(:account, :rule)
      .where.not(accounts: {space_id: nil})
      .where.not(rules: {space_id: nil})
      .where("accounts.space_id != rules.space_id")
      .includes(:account, :rule)
  end

  def fix_mismatched_rules(mismatched_rules)
    fixed_count = 0
    mismatched_rules.each do |account_rule|
      account_space = account_rule.account.space_id
      rule_name = account_rule.rule.name

      # Find the matching rule in the correct space
      correct_rule = Rule.find_by(name: rule_name, space_id: account_space)

      if correct_rule
        account_rule.update_column(:rule_id, correct_rule.id)
        puts "      Fixed AR ##{account_rule.id}: #{rule_name} (#{account_rule.rule.space_id} -> #{account_space})"
        fixed_count += 1
      else
        puts "      WARNING: No matching rule '#{rule_name}' found in space #{account_space}"
      end
    end
    fixed_count
  end

  def fix_orphaned_rules
    orphaned_rules = Rule.where(space_id: nil)
    return unless orphaned_rules.any?

    puts "  Found #{orphaned_rules.count} orphaned rules"
    puts "  Duplicating to all spaces..."

    all_spaces = Space.all
    all_spaces.each_with_index do |space, index|
      orphaned_rules.each do |rule|
        if index.zero?
          # First space gets the original rules
          rule.update_column(:space_id, space.id)
        else
          # Other spaces get duplicates
          new_rule = rule.dup
          new_rule.space_id = space.id
          new_rule.save!
        end
      end
      puts "    ✅ Assigned #{orphaned_rules.count} rules to #{space.name}"
    end
  end

  def check_final_status
    null_counts = {
      accounts: Account.where(space_id: nil).count,
      rules: Rule.where(space_id: nil).count,
      firms: Firm.where(space_id: nil).count,
      trades: Trade.where(space_id: nil).count,
      expenses: Expense.where(space_id: nil).count,
      tags: Tag.where(space_id: nil).count
    }

    if null_counts.values.sum.zero?
      puts "\n  ✅ All records have been assigned to spaces!"
    else
      puts "\n  ⚠️  Warning: Some records still have null space_ids:"
      null_counts.each do |model, count|
        puts "    #{model.to_s.titleize}: #{count}" if count.positive?
      end
    end
  end
end
