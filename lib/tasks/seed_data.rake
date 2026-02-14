# frozen_string_literal: true

namespace :seed do
  desc "Seed development data with realistic prop trading firm data (with space)"
  task data: :environment do
    seed_with_space
  end

  desc "Create sample space with full data"
  task space: :environment do
    space = create_space
    puts "Created space: #{space.name} (ID: #{space.id})"
  end

  desc "Create individual sample firm"
  task firm: :environment do
    firm = create_firms.first
    puts "Created firm: #{firm.name} (ID: #{firm.id})"
  end

  desc "Create all standard rules"
  task rules: :environment do
    rules = create_rules
    puts "Created #{rules.count} rules"
    rules.each do |rule|
      puts "  - #{rule.name} (#{rule.rule_type})"
    end
  end

  desc "Create sample user"
  task user: :environment do
    user = create_user
    puts "Created user: #{user.email} (ID: #{user.id})"
  end

  desc "Create sample account with associations"
  task account: :environment do
    user = User.first || create_user
    firms = Firm.limit(1)
    firms = create_firms if firms.empty?

    accounts = create_accounts(user, firms)
    account = accounts.first

    puts "Created account: #{account.name || "Account ##{account.id}"} (ID: #{account.id})"
    puts "  Firm: #{account.firm.name}"
    puts "  User: #{account.user.email}"
  end

  desc "Create sample trades for existing accounts"
  task trades: :environment do
    accounts = Account.limit(1)
    if accounts.empty?
      puts "No accounts found. Creating sample account first..."
      Rake::Task["seed:account"].invoke
      accounts = Account.limit(1)
    end

    trades_count = create_trades(accounts)
    puts "Created #{trades_count} trades for account: #{accounts.first.name || "Account ##{accounts.first.id}"}"
  end

  private

  def challenge_balances
    [25_000, 50_000, 100_000].freeze
  end

  def verification_balances
    [50_000, 100_000].freeze
  end

  def funded_balances
    [100_000, 250_000, 500_000].freeze
  end

  def trade_directions
    [true, false].freeze
  end

  def volumes
    [0.1, 0.2, 0.5, 1.0, 2.0].freeze
  end

  def emotional_states
    %w[confident nervous excited calm anxious].freeze
  end

  def market_conditions
    %w[trending ranging volatile quiet].freeze
  end

  def trade_grades
    %w[A B C D F].freeze
  end

  def create_user
    User.find_or_create_by(email: "trader@example.com") do |user|
      user.password = "password123"
      user.password_confirmation = "password123"
      user.first_name = "John"
      user.last_name = "Trader"
      user.country_code = "US"
      user.timezone = "America/New_York"
      user.status = "active"
      user.date_of_birth = 25.years.ago.to_date
      user.uuid = SecureRandom.uuid
      user.confirmed_at = Time.current
      user.preferences = {
        notifications: true,
        theme: "light",
        language: "en",
        trading_notifications: true,
        risk_alerts: true
      }.to_json
    end
  end

  def create_firms
    firm_data.map { |data| create_firm(data) }
  end

  def firm_data
    [
      alpha_trading_data,
      quantum_capital_data,
      precision_prop_data
    ]
  end

  def alpha_trading_data
    {
      name: "Alpha Trading Partners",
      legal_name: "Alpha Trading Partners LLC",
      description: "Premier prop trading firm specializing in forex and futures",
      website_url: "https://alphatrading.com",
      founding_date: 5.years.ago.to_date,
      country_code: "US",
      contact_info: alpha_contact_info.to_json,
      metadata: alpha_metadata.to_json
    }
  end

  def quantum_capital_data
    {
      name: "Quantum Capital Group",
      legal_name: "Quantum Capital Group Ltd",
      description: "Algorithmic trading specialists with advanced risk management",
      website_url: "https://quantumcapital.co.uk",
      founding_date: 3.years.ago.to_date,
      country_code: "GB",
      contact_info: quantum_contact_info.to_json,
      metadata: quantum_metadata.to_json
    }
  end

  def precision_prop_data
    {
      name: "Precision Prop Trading",
      legal_name: "Precision Prop Trading Pte Ltd",
      description: "Asian markets focused proprietary trading firm",
      website_url: "https://precisionprop.sg",
      founding_date: 7.years.ago.to_date,
      country_code: "SG",
      contact_info: precision_contact_info.to_json,
      metadata: precision_metadata.to_json
    }
  end

  def alpha_contact_info
    {
      email: "info@alphatrading.com",
      phone: "+1-555-0101",
      address: "123 Wall Street, New York, NY"
    }
  end

  def alpha_metadata
    {
      trading_styles: %w[day_trading scalping],
      min_account_size: 25_000,
      max_drawdown_allowed: 0.08,
      payout_schedule: "monthly"
    }
  end

  def quantum_contact_info
    {
      email: "contact@quantumcapital.co.uk",
      phone: "+44-20-7946-0958",
      address: "45 Bishopsgate, London, UK"
    }
  end

  def quantum_metadata
    {
      trading_styles: %w[swing_trading algorithmic],
      min_account_size: 50_000,
      max_drawdown_allowed: 0.10,
      payout_schedule: "bi_weekly"
    }
  end

  def precision_contact_info
    {
      email: "support@precisionprop.sg",
      phone: "+65-6123-4567",
      address: "1 Raffles Place, Singapore"
    }
  end

  def precision_metadata
    {
      trading_styles: %w[day_trading news_trading],
      min_account_size: 10_000,
      max_drawdown_allowed: 0.12,
      payout_schedule: "weekly"
    }
  end

  def create_firm(data)
    Firm.find_or_create_by(name: data[:name]) do |firm|
      assign_firm_attributes(firm, data)
    end
  end

  def assign_firm_attributes(firm, data)
    firm.legal_name = data[:legal_name]
    firm.description = data[:description]
    firm.website_url = data[:website_url]
    firm.founding_date = data[:founding_date]
    firm.country_code = data[:country_code]
    firm.contact_info = data[:contact_info]
    firm.metadata = data[:metadata]
    firm.status = "active"
  end

  def create_rules
    rule_definitions.map { |data| create_rule(data) }
  end

  def rule_definitions
    [
      max_contracts_rule,
      daily_loss_limit_rule,
      trailing_max_drawdown_rule,
      drawdown_mode_rule,
      consistency_rule_updated,
      max_accounts_rule
    ]
  end

  def max_contracts_rule
    {
      name: "Max Contracts",
      rule_type: "risk_management",
      data_type: "integer_count",
      calculation_method: "max_contracts",
      time_scope: "per_trade",
      violation_action: "hard_breach",
      validation_config: {"max" => 1, "micros_equivalent" => 10},
      description: "Maximum 1 Mini (10 Micros) contract per trade"
    }
  end

  def daily_loss_limit_rule
    {
      name: "Daily Loss Limit",
      rule_type: "risk_management",
      data_type: "currency_amount",
      calculation_method: "daily_loss",
      time_scope: "daily",
      violation_action: "hard_breach",
      validation_config: {"max" => nil, "note" => "None"},
      description: "No daily loss limit applied"
    }
  end

  def trailing_max_drawdown_rule
    {
      name: "Trailing Max Drawdown",
      rule_type: "risk_management",
      data_type: "currency_amount",
      calculation_method: "trailing_drawdown",
      time_scope: "lifetime",
      violation_action: "hard_breach",
      validation_config: {"max" => 1000},
      description: "Maximum trailing drawdown of $1,000"
    }
  end

  def drawdown_mode_rule
    {
      name: "Drawdown Mode",
      rule_type: "risk_management",
      data_type: "boolean_flag",
      calculation_method: "drawdown_mode",
      time_scope: "daily",
      violation_action: "hard_breach",
      validation_config: {"mode" => "end_of_day"},
      description: "Drawdown calculated at end of day"
    }
  end

  def consistency_rule_updated
    {
      name: "Consistency",
      rule_type: "payout_eligibility",
      data_type: "percentage",
      calculation_method: "consistency_ratio",
      time_scope: "rolling_30",
      violation_action: "payout_block",
      validation_config: {
        "min" => 20.0,
        "payout_2" => 25.0,
        "payout_3_plus" => 30.0,
        "note" => "Increases to 25% for Payout 2 and 30% for Payout 3+"
      },
      description: "Consistency requirement: 20% (increases for subsequent payouts)"
    }
  end

  def max_accounts_rule
    {
      name: "Max Accounts",
      rule_type: "account_lifecycle",
      data_type: "integer_count",
      calculation_method: "simple_threshold",
      time_scope: "lifetime",
      violation_action: "hard_breach",
      validation_config: {"max" => 5},
      description: "Maximum 5 accounts per user"
    }
  end

  def daily_loss_rule
    {
      name: "Daily Loss Limit",
      rule_type: "risk_management",
      data_type: "percentage",
      calculation_method: "daily_loss",
      time_scope: "daily",
      violation_action: "hard_breach",
      validation_config: {"max" => 5.0},
      description: "Maximum daily loss of 5% of account balance"
    }
  end

  def maximum_drawdown_rule
    {
      name: "Maximum Drawdown",
      rule_type: "risk_management",
      data_type: "percentage",
      calculation_method: "total_drawdown",
      time_scope: "lifetime",
      violation_action: "hard_breach",
      validation_config: {"max" => 10.0},
      description: "Maximum drawdown of 10% from initial balance"
    }
  end

  def profit_target_rule
    {
      name: "Profit Target",
      rule_type: "payout_eligibility",
      data_type: "percentage",
      calculation_method: "simple_threshold",
      time_scope: "lifetime",
      violation_action: "payout_block",
      validation_config: {"min" => 8.0},
      description: "Must achieve 8% profit for payout eligibility"
    }
  end

  def minimum_trading_days_rule
    {
      name: "Minimum Trading Days",
      rule_type: "payout_eligibility",
      data_type: "integer_count",
      calculation_method: "trading_days",
      time_scope: "rolling_30",
      violation_action: "payout_block",
      validation_config: {"min" => 10},
      description: "Must trade at least 10 days in 30-day period"
    }
  end

  def position_size_rule
    {
      name: "Position Size Limit",
      rule_type: "risk_management",
      data_type: "percentage",
      calculation_method: "position_size",
      time_scope: "per_trade",
      violation_action: "soft_warning",
      validation_config: {"max" => 2.0},
      description: "Maximum 2% risk per trade"
    }
  end

  def consistency_rule
    {
      name: "Consistency Ratio",
      rule_type: "trading_behavior",
      data_type: "percentage",
      calculation_method: "consistency_ratio",
      time_scope: "rolling_30",
      violation_action: "soft_warning",
      validation_config: {"min" => 60.0},
      description: "Must maintain 60% win rate over 30 days"
    }
  end

  def news_trading_rule
    {
      name: "News Trading Restriction",
      rule_type: "trading_behavior",
      data_type: "boolean_flag",
      calculation_method: "simple_threshold",
      time_scope: "per_trade",
      violation_action: "hard_breach",
      validation_config: {"forbidden_times" => %w[30_min_before_news 30_min_after_news]},
      description: "No trading 30 minutes before/after major news events"
    }
  end

  def weekend_hold_rule
    {
      name: "Weekend Hold Restriction",
      rule_type: "trading_behavior",
      data_type: "boolean_flag",
      calculation_method: "simple_threshold",
      time_scope: "per_trade",
      violation_action: "hard_breach",
      validation_config: {"no_weekend_holds" => true},
      description: "Positions must be closed before weekend"
    }
  end

  def leverage_rule
    {
      name: "Maximum Leverage",
      rule_type: "risk_management",
      data_type: "integer_count",
      calculation_method: "simple_threshold",
      time_scope: "per_trade",
      violation_action: "hard_breach",
      validation_config: {"max" => 100},
      description: "Maximum leverage of 1:100"
    }
  end

  def inactivity_rule
    {
      name: "Account Inactivity Rule",
      rule_type: "account_lifecycle",
      data_type: "time_duration",
      calculation_method: "simple_threshold",
      time_scope: "lifetime",
      violation_action: "soft_warning",
      validation_config: {"max_days_inactive" => 30},
      description: "Warning after 30 days of inactivity"
    }
  end

  def create_rule(data)
    Rule.find_or_create_by(name: data[:name]) do |rule|
      assign_rule_attributes(rule, data)
    end
  end

  def assign_rule_attributes(rule, data)
    rule.rule_type = data[:rule_type]
    rule.data_type = data[:data_type]
    rule.calculation_method = data[:calculation_method]
    rule.time_scope = data[:time_scope]
    rule.violation_action = data[:violation_action]
    rule.validation_config = data[:validation_config]
    rule.description = data[:description]
    rule.is_active = true
  end

  def associate_rules_with_firms(firms, rules)
    firms.each do |firm|
      # Each firm gets 6-8 random rules
      selected_rules = rules.sample(rand(6..8))

      selected_rules.each do |rule|
        FirmRule.find_or_create_by(firm: firm, rule: rule) do |firm_rule|
          firm_rule.start_date = 30.days.ago
          firm_rule.is_active = true
        end
      end
    end
  end

  def create_accounts(user, firms)
    phases = %w[evaluation funded]
    accounts = []

    firms.each do |firm|
      # Create 1 account per firm for the user
      phase = phases.sample

      accounts << Account.find_or_create_by(
        user: user,
        firm: firm,
        uuid: SecureRandom.uuid
      ) do |account|
        account.phase = phase
        account.name = "#{phase.titleize} Account - #{firm.name}"
        account.initial_balance = case phase
                                  when "evaluation" then challenge_balances.sample
                                  when "funded" then funded_balances.sample
                                  end
        account.currency = "USD"
        account.status = "active"
        account.start_date = rand(30..90).days.ago
        account.template = false
      end
    end

    accounts
  end

  def associate_rules_with_accounts(accounts, _rules)
    accounts.each do |account|
      # Get firm rules for this account's firm
      firm_rules = account.firm.firm_rules.includes(:rule)

      firm_rules.each do |firm_rule|
        AccountRule.find_or_create_by(
          account: account,
          rule: firm_rule.rule
        ) do |account_rule|
          account_rule.start_date = account.start_date
          account_rule.is_active = true
          account_rule.rule_parameters = firm_rule.rule_parameters
        end
      end
    end
  end

  def create_trades(accounts)
    total_trades = 0
    symbols = %w[EURUSD GBPUSD USDJPY AUDUSD USDCAD USDCHF NZDUSD EURJPY GBPJPY EURGBP XAUUSD XAGUSD NAS100 SPX500 US30]
    strategies = %w[scalping swing_trading day_trading momentum breakout reversal]

    accounts.each do |account|
      trades_count = rand(30..35)
      total_trades += create_account_trades(account, trades_count, symbols, strategies)
    end

    total_trades
  end

  def create_account_trades(account, trades_count, symbols, strategies)
    created_count = 0

    trades_count.times do |i|
      trade_data = generate_trade_data(account, i, symbols, strategies)
      Trade.create!(trade_data)
      created_count += 1
    end

    created_count
  end

  def generate_trade_data(account, index, symbols, strategies)
    trade_data = {
      account: account,
      index: index,
      symbols: symbols,
      strategies: strategies
    }

    basic_data = generate_basic_trade_data(account)
    pricing_data = generate_pricing_data(basic_data)
    timing_data = generate_timing_data(basic_data[:trade_date])

    build_trade_hash(trade_data.merge(basic_data: basic_data, pricing_data: pricing_data, timing_data: timing_data))
  end

  def generate_basic_trade_data(account)
    {
      trade_date: random_trade_date(account),
      entry_price: rand(1.0000..1.5000).round(5),
      is_long: trade_directions.sample,
      pip_movement: rand(-150..200),
      pip_value: 10
    }
  end

  def generate_pricing_data(basic_data)
    exit_price = calculate_exit_price(basic_data[:entry_price], basic_data[:is_long], basic_data[:pip_movement])
    pnl = calculate_pnl(basic_data[:pip_movement], basic_data[:pip_value])
    stop_distance, profit_distance = calculate_distances
    risk_reward = (profit_distance / stop_distance).round(2)

    {
      exit_price: exit_price,
      pnl: pnl,
      stop_distance: stop_distance,
      profit_distance: profit_distance,
      risk_reward: risk_reward
    }
  end

  def generate_timing_data(trade_date)
    entry_time = random_entry_time(trade_date)
    exit_time = entry_time + rand(5..240).minutes

    {entry_time: entry_time, exit_time: exit_time}
  end

  def build_trade_hash(data)
    account = data[:account]
    index = data[:index]
    symbols = data[:symbols]
    strategies = data[:strategies]
    basic_data = data[:basic_data]
    pricing_data = data[:pricing_data]
    timing_data = data[:timing_data]

    build_core_trade_attributes(account, index, symbols, strategies, basic_data, pricing_data, timing_data)
  end

  def build_core_trade_attributes(account, index, symbols, strategies, basic_data, pricing_data, timing_data)
    {
      account: account,
      uuid: SecureRandom.uuid,
      trade_date: basic_data[:trade_date],
      entry_time: timing_data[:entry_time],
      exit_time: timing_data[:exit_time],
      symbol: symbols.sample,
      trade_type: basic_data[:is_long] ? "buy" : "sell",
      strategy: strategies.sample,
      entry_price: basic_data[:entry_price],
      exit_price: pricing_data[:exit_price],
      volume: volumes.sample,
      pnl: pricing_data[:pnl].round(2),
      commission: rand(1.0..5.0).round(2),
      swap: rand(-2.0..2.0).round(2),
      stop_loss: calculate_stop_loss(basic_data[:entry_price], basic_data[:is_long], pricing_data[:stop_distance]),
      take_profit: calculate_take_profit(
        basic_data[:entry_price],
        basic_data[:is_long],
        pricing_data[:profit_distance]
      ),
      risk_reward_ratio: pricing_data[:risk_reward],
      duration_minutes: ((timing_data[:exit_time] - timing_data[:entry_time]) / 1.minute).round,
      is_winning_trade: pricing_data[:pnl] > 0,
      emotional_state: emotional_states.sample,
      market_condition: market_conditions.sample,
      trade_grade: trade_grades.sample,
      external_trade_id: "TRD-#{account.id}-#{basic_data[:trade_date].strftime("%Y%m%d")}-#{index + 1}"
    }
  end

  def random_trade_date(account)
    start_date = account.start_date || 30.days.ago.to_date
    start_date + rand(0..(Date.current - start_date).to_i).days
  end

  def calculate_exit_price(entry_price, is_long, pip_movement)
    if is_long
      entry_price + (pip_movement * 0.0001)
    else
      entry_price - (pip_movement * 0.0001)
    end
  end

  def calculate_pnl(pip_movement, pip_value)
    pnl = pip_movement * pip_value
    pnl *= rand(2..5) if rand(100) < 10 # 10% chance for bigger wins/losses
    pnl
  end

  def random_entry_time(trade_date)
    trade_date.beginning_of_day + rand(8..16).hours + rand(0..59).minutes
  end

  def calculate_distances
    stop_distance = rand(10..50) * 0.0001
    profit_distance = rand(20..100) * 0.0001
    [stop_distance, profit_distance]
  end

  def calculate_stop_loss(entry_price, is_long, stop_distance)
    is_long ? entry_price - stop_distance : entry_price + stop_distance
  end

  def calculate_take_profit(entry_price, is_long, profit_distance)
    is_long ? entry_price + profit_distance : entry_price - profit_distance
  end

  def seed_with_space
    puts "🌱 Starting seed data generation with space..."

    # Create user
    user = create_user
    puts "✓ Created user: #{user.email}"

    # Create space and membership
    space = create_space_with_membership(user)
    puts "✓ Created space: #{space.name}"

    # Set tenant context
    ActsAsTenant.with_tenant(space) do
      firms = create_firms
      puts "✓ Created #{firms.count} firms in space"

      rules = create_rules
      puts "✓ Created #{rules.count} rules in space"

      associate_rules_with_firms(firms, rules)
      puts "✓ Associated rules with firms"

      accounts = create_accounts(user, firms)
      puts "✓ Created #{accounts.count} accounts"

      associate_rules_with_accounts(accounts, rules)
      puts "✓ Associated rules with accounts"

      trades_count = create_trades(accounts)
      puts "✓ Created #{trades_count} trades"

      print_summary(space, firms, rules, accounts, trades_count)
    end
  end

  def seed_all_data
    puts "🌱 Starting legacy seed data generation (without space)..."
    puts "⚠️  Warning: This will create data without a space association"
    puts "Use 'rake seed:data' instead for proper multi-tenant setup"

    user = create_user
    puts "✓ Created user: #{user.email}"

    # Create firms without tenant context (will need manual space_id assignment)
    ActsAsTenant.without_tenant do
      firms = create_firms
      puts "✓ Created #{firms.count} firms"

      rules = create_rules
      puts "✓ Created #{rules.count} rules"

      associate_rules_with_firms(firms, rules)
      puts "✓ Associated rules with firms"

      accounts = create_accounts(user, firms)
      puts "✓ Created #{accounts.count} accounts"

      associate_rules_with_accounts(accounts, rules)
      puts "✓ Associated rules with accounts"

      trades_count = create_trades(accounts)
      puts "✓ Created #{trades_count} trades"

      print_summary(nil, firms, rules, accounts, trades_count)
    end
  end

  def create_space_with_membership(user)
    space = Space.find_or_create_by(name: "My Trading Space") do |s|
      s.description = "Main trading workspace"
      s.status = "active"
      s.settings = {
        currency: "USD",
        timezone: "America/New_York",
        notifications_enabled: true
      }
    end

    # Create membership if it doesn't exist
    SpaceMembership.find_or_create_by(user: user, space: space) do |membership|
      membership.role = "owner"
      membership.status = "active"
    end

    space
  end

  def create_space
    user = User.first || create_user
    create_space_with_membership(user)
  end

  def print_summary(space, firms, rules, accounts, trades_count)
    puts "🎉 Seed data generation complete!"
    puts "📊 Summary:"
    puts "   - Space: #{space&.name || "None (legacy mode)"}"
    puts "   - Users: 1"
    puts "   - Firms: #{firms.count}"
    puts "   - Rules: #{rules.count}"
    puts "   - Accounts: #{accounts.count}"
    puts "   - Trades: #{trades_count}"
  end
end
