# Claude Development Guidelines

## Session Startup

**IMPORTANT**: At the start of every session, read and display the contents of `.claude/TODO.md` to provide context on current tasks and priorities.

## Project Overview

After each create, edit or delete:
- ensure erb lint conformity (with cache: `bundle exec erb_lint --lint-all --cache`)
- ensure rubocop conformity
- ensure tests are added, deleted or updated, to enrich the understanding of the domain

This is a Rails 8 application for prop trading firms to manage accounts, trades, and risk rules. The application uses:
- **Backend**: Rails 8 with PostgreSQL
- **Frontend**: Tailwind CSS v4 with Vite Rails
- **Authentication**: Devise
- **Admin Interface**: Madmin with custom styling and navigation
- **Multi-tenancy**: Spaces with ActsAsTenant for data isolation

## Code Style & Standards

### Ruby/Rails Conventions
- Always add frozen string literals: `# frozen_string_literal: true` at top of all Ruby files
- Follow Rails conventions: Use standard Rails patterns and naming
- Integer primary keys: Use integer IDs for performance with optional UUID columns for security
- No unnecessary comments: Only add comments when explicitly requested
- Prefer editing existing files: Never create new files unless absolutely necessary

### Linting & Quality
- **Rubocop**: `bundle exec rubocop --autocorrect`
- **ERB Lint**: `bundle exec erb_lint --lint-all --autocorrect`
- **Stylelint**: `npx stylelint "app/frontend/entrypoints/*.css" --fix`
- Always run linting before finishing tasks

#### RuboCop Configuration (.rubocop.yml)
**Key Rules to Follow:**

**Metrics & Limits:**
- `Metrics/ClassLength`: Max 200 lines (excluded: test/**)
- `Metrics/MethodLength`: Max 25 lines (excluded: bin/setup, db/migrate/*, test/**, lib/tasks/**, app/controllers/madmin/**)
- `Metrics/BlockLength`: Max 25 lines (excluded: config/**, test/**, lib/tasks/**)
- `Metrics/ModuleLength`: Max 200 lines (excluded: config/**)
- `Metrics/ParameterLists`: Max 6 parameters (excluded: lib/tasks/**)
- `Metrics/PerceivedComplexity`: Max 8 (excluded: bin/setup, app/controllers/madmin/**)
- `Metrics/AbcSize`: Disabled
- `Metrics/CyclomaticComplexity`: Disabled

**Layout & Formatting:**
- `Layout/ArgumentAlignment`: Fixed indentation style
- `Layout/SpaceInsideHashLiteralBraces`: No spaces (`{key: value}` not `{ key: value }`)
- `Layout/FirstArrayElementLineBreak`: Enabled (multiline arrays start on new line)
- `Layout/FirstHashElementLineBreak`: Enabled (multiline hashes start on new line)
- `Layout/FirstMethodArgumentLineBreak`: Enabled (multiline args start on new line)
- `Layout/HashAlignment`: Align by keys (both rockets and colons)
- `Layout/MultilineMethodCallIndentation`: Indented style
- `Layout/MultilineOperationIndentation`: Indented style

**Style Preferences:**
- `Style/StringLiterals`: Double quotes (`"string"` not `'string'`)
- `Style/StringLiteralsInInterpolation`: Double quotes
- `Style/EmptyMethod`: Expanded style (no one-liner methods)
- `Style/Documentation`: Disabled (no class documentation required)
- `Style/GuardClause`: Disabled (early returns not enforced)
- `Style/IfUnlessModifier`: Disabled (inline conditionals not enforced)
- `Style/FrozenStringLiteralComment`: Required in Ruby files

**Rails-specific:**
- `Rails/DefaultScope`: Enabled (avoid default_scope)
- `Rails/RequireDependency`: Enabled (require dependencies explicitly)
- `Rails/SkipsModelValidations`: Disabled (allow update_column, etc.)
- `Rails/StrongParametersExpect`: Disabled (use require().permit() for nested attributes)
- `Rails/BulkChangeTable`: Disabled
- `Rails/NotNullColumn`: Disabled (allow NOT NULL additions)

**Disabled Cops:**
- `Style/ClassAndModuleChildren`: Disabled (allow compact vs nested module style)
- `Style/DoubleNegation`: Disabled (allow `!!value`)
- `Lint/AmbiguousBlockAssociation`: Disabled
- `Naming/MemoizedInstanceVariableName`: Disabled
- `Naming/VariableNumber`: Disabled

#### ERB Lint Configuration (.erb_lint.yml)
**Key Rules:**
- `EnableDefaultLinters: true` - All standard linters active
- `ErbSafety`: Enabled (check for XSS vulnerabilities)
- `Rubocop`: Enabled (runs RuboCop on Ruby code within ERB)
  - Inherits from `.rubocop.yml`
  - Special ERB exclusions:
    - `Layout/InitialIndentation`: Disabled
    - `Layout/TrailingEmptyLines`: Disabled
    - `Lint/UselessAssignment`: Disabled
    - `Naming/FileName`: Disabled
    - `Rails/OutputSafety`: Disabled (allow `raw`, `html_safe`)
    - `Style/FrozenStringLiteralComment`: Disabled (not needed in ERB)

**Available Linters:**
- `allowed_script_type`, `closing_erb_tag_indent`, `comment_syntax`
- `deprecated_classes`, `erb_safety`, `extra_newline`, `final_newline`
- `hard_coded_string`, `no_javascript_tag_helper`, `no_unused_disable`
- `parser_errors`, `partial_instance_variable`, `require_input_autocomplete`
- `require_script_nonce`, `right_trim`, `rubocop`, `rubocop_text`
- `self_closing_tag`, `space_around_erb_tag`, `space_in_html_tag`
- `space_indentation`, `strict_locals`, `trailing_whitespace`

**When Creating Code:**
1. **Ruby Files**: Always include `# frozen_string_literal: true`
2. **Methods**: Keep under 25 lines (extract to private methods if needed)
3. **Classes**: Keep under 200 lines (extract to service/concern if needed)
4. **Strings**: Use double quotes consistently
5. **Hashes**: No spaces inside braces `{key: value}`
6. **Multiline**: Break arrays/hashes/args onto new lines
7. **ERB Files**: Focus on readability, indentation, and XSS safety
8. **Service Classes**: May exceed 200 lines if containing data definitions (like seed data)

## Database & Migrations

### ID Strategy
- **Primary Keys**: Integer IDs for optimal join performance
- **Security**: UUID columns for sensitive tables (users, accounts, trades)
- **Public URLs**: Use UUID in routes (`/accounts/{uuid}`) via `to_param` method
- **Internal joins**: Fast integer foreign keys for all relationships

## Frontend Architecture

### Admin Interface (Madmin)
- **Layout**: Custom layout using main app navigation at `app/views/layouts/madmin/application.html.erb`
- **Styling**: Dedicated CSS entrypoint at `app/frontend/entrypoints/madmin.css` processed by Vite
- **Navigation**: Custom sidebar navigation with:
  - Dashboard link
  - Quick Actions section (Quick Add Trades)
  - Auto-generated Madmin menu items for all resources
- **Forms**: Enhanced with dropdown selects using `:select, collection:` syntax for enum fields
- **Quick Actions**: Bulk trade creation feature for multiple accounts with same date/symbol

### CSS Architecture
- **Madmin Styling**: Custom CSS with utility-first approach, ID selectors allowed for admin interface
- **Tailwind CSS v4**: PostCSS processing with `@import "tailwindcss";`
- **Mobile-first**: Always design mobile-first responsive layouts

### JavaScript
- **Stimulus controllers**: Use for interactive functionality (e.g., quick trade form)
- **ES6+ syntax**: Modern JavaScript patterns with minimal dependencies

## Model Architecture

### Core Domain Models

#### Trade Model
- **Constants**: `TRADE_TYPES = %w[buy sell].freeze`, `SYMBOLS` with common trading pairs
- **Validations**: Trade date, P&L presence, trade type inclusion, UUID uniqueness
- **Callbacks**: `before_save :calculate_derived_fields` for automatic calculations
- **Scopes**: `profitable`, `losing`, `break_even`, `by_symbol`, `by_strategy`, `recent`
- **Key Methods**:
  - `duration_in_minutes` - calculated trade duration
  - `calculate_risk_reward_ratio` - risk/reward analysis
  - Performance categorization (`profitable?`, `losing?`, `break_even?`)

#### Account Model
- **Constants**: `ACCOUNT_TYPES`, `STATUSES` for validation and consistency
- **Validations**: UUID uniqueness, positive balances, date ranges
- **Key Methods**:
  - `current_balance` - calculated from initial balance + trades P&L
  - `profit_loss_percentage` - performance calculation
  - `trading_days_count(period)` - activity metrics

#### Rule Model
- **Constants**: Comprehensive enum constants for rule types, data types, calculation methods
- **Validations**: All fields required with inclusion validation
- **Key Methods**:
  - `threshold_value` - extracts max/min from validation config
  - `minimum?`/`maximum?` - validation config analysis

### Madmin Resource Configuration

#### Best Practices
- **Field Ordering**: Most important fields first with `index: true`
- **Enum Fields**: Use `:select, collection: ModelName::CONSTANT` for dropdowns
- **Field Types**: Use built-in Madmin field types (`:number`, `:string`, `:select`, etc.) - avoid custom field types
- **Form Exclusions**: Use `form: false` for calculated/read-only fields (id, timestamps)
- **Example Pattern**:
```ruby
class ExampleResource < Madmin::Resource
  attribute :id, form: false
  # Index/Table Attributes (most important first)
  attribute :name, index: true
  attribute :status, :select, collection: Model::STATUSES, index: true

  # Additional attributes for forms and detail view
  attribute :description
  attribute :created_at, form: false
  attribute :updated_at, form: false

  # Associations
  attribute :related_models
end
```

## Development Data

### Seed Data Tasks
```bash
# Complete development dataset
rake seed:data        # Creates full ecosystem: users, firms, rules, accounts, trades

# Individual object creation
rake seed:firm        # Creates sample firm with complete business details
rake seed:rules       # Creates all 10 standard rules
rake seed:account     # Creates account with user/firm associations
rake seed:user        # Creates authenticated user
rake seed:trades      # Creates sample trades for existing accounts
```

### Sample Data Features
- **3 Professional Firms**: Alpha Trading Partners (US), Quantum Capital (UK), Precision Prop (SG)
- **10 Standard Rules**: Complete coverage of risk management, payout eligibility, trading behavior
- **Multiple Accounts**: Challenge, verification, and funded account types per firm
- **Realistic Trades**: 30-35 trades per account with proper metadata and relationships
- **Complete Relationships**: Firms ↔ Rules ↔ Accounts ↔ Users ↔ Trades

## Database Management

### Production Database Scripts
Located in `scripts/` directory for backing up and restoring production data.

#### Download Fresh Production DB
Creates a new backup from Heroku and restores locally (2-3 minutes):
```bash
./scripts/backup_and_restore_production.sh
```

**What it does:**
1. Creates fresh Heroku backup
2. Downloads backup to `scripts/backups/`
3. Drops local database
4. Restores from backup
5. Runs migrations
6. Runs space backfill task

#### Restore from Existing Backup
Restore from a local backup file (30-60 seconds):
```bash
# Use most recent backup
./scripts/restore_from_backup.sh

# Use specific backup
./scripts/restore_from_backup.sh scripts/backups/etc
```

#### Backup Storage
- **Location**: `scripts/backups/`
- **Format**: PostgreSQL dump files (`.dump`)
- **Naming**: `production_YYYYMMDD_HHMMSS.dump`
- **Git**: Ignored by `.gitignore`

## Development Workflow

1. **Setup**: `bin/rails db:create db:migrate`
2. **Seed Data**: `rake seed:data` for complete development environment
3. **Production Data**: `./scripts/backup_and_restore_production.sh` to download latest prod DB
4. **Admin Access**: Navigate to `/madmin` for admin interface
5. **Linting**: Run linting commands before commits:
   ```bash
   bundle exec rubocop --autocorrect
   bundle exec erb_lint --autocorrect app/views/
   npx stylelint "app/frontend/entrypoints/*.css" --fix
   ```
6. **Testing**: Use individual seed tasks for specific test scenarios

## Key Features

### Quick Add Trades
- **Location**: `/madmin/quick_trades/new`
- **Purpose**: Bulk trade creation for multiple accounts with same date/symbol
- **Controller**: `app/controllers/madmin/quick_trades_controller.rb`
- **View**: `app/views/madmin/quick_trades/new.html.erb`
- **JavaScript**: `app/frontend/controllers/quick_trade_controller.js` (Stimulus)

### User Impersonation (Pretender)
- **Gem**: `pretender` - for testing as other users
- **Setup**: `impersonates :user` in both `ApplicationController` and `Madmin::ApplicationController`
- **Controllers**: `UsersController` handles `impersonate` and `stop_impersonating` actions
- **Routes**: `POST /users/:id/impersonate` and `POST /users/stop_impersonating`
- **UI**: Yellow banner in header when impersonating with "Stop Impersonating" button
- **Methods**: `impersonate_user(user)`, `stop_impersonating_user`, `true_user`, check `current_user != true_user`

### Trade Constants
- **Trade Types**: Buy/Sell dropdown with validation
- **Symbols**: Common trading pairs including forex, indices, crypto, metals
- **Usage**: Both constants used in forms and validation throughout the application

## Controller Architecture

### Madmin Controller Hierarchy
```
ActionController::Base
├── ApplicationController (has Devise, Pretender)
│   └── UsersController
│
└── Madmin::BaseController
    └── Madmin::ApplicationController (has Pretender)
        ├── Madmin::DashboardController
        ├── Madmin::TradesController
        ├── Madmin::AccountsController
        └── ... (all Madmin resources)
```

**Important**: Madmin controllers inherit from `Madmin::BaseController`, NOT from `ApplicationController`. Any shared functionality (like Pretender) must be added to `Madmin::ApplicationController`.

### Data Scoping Best Practices
- **Always scope to current user**: Filter data by `current_user` to prevent data leaks
- **Example**: `Trade.where(account: current_user.accounts)` ensures users only see their own trades
- **Security**: Never expose system-wide data without proper user scoping

## Multi-Tenancy with Spaces

### Overview
The application uses **Spaces** for multi-tenancy, allowing complete data isolation between different workspaces. Each user can have multiple spaces, and all core data (firms, rules, accounts, trades) is scoped to a specific space.

### Space Architecture

#### Models
- **Space**: The tenant model - represents a workspace
  - Fields: `name`, `description`, `status` (active/inactive), `settings` (jsonb)
  - Has many: `space_memberships`, `users` (through memberships), `firms`, `rules`, `accounts`, `trades`

- **SpaceMembership**: Join table for users and spaces
  - Fields: `role` (owner/admin/member), `status` (active/invited/inactive)
  - Belongs to: `user`, `space`

#### Tenant Scoping
All multi-tenant models use `acts_as_tenant :space`:
- `Firm`
- `Rule`
- `Account`
- `Trade`
- `AccountBalance`
- `Expense`
- `Tag`
- And all association tables (FirmRule, AccountRule, TradeTag, etc.)

### Space Management

#### Automatic Space Creation
When a user signs up, a default space is automatically created:
```ruby
# In Users::RegistrationsController
space = Space.create!(
  name: "#{user.email.split("@").first.titleize}'s Space",
  status: "active"
)

# Create membership as owner
space.space_memberships.create!(
  user: user,
  role: "owner",
  status: "active"
)

# Automatically seed 17 account type rules for the new space
AccountTypeRulesSeeder.seed_for_space(space)
```

#### Current Space Management
- **Session Storage**: Current space stored in `session[:current_space_id]`
- **Controller Setup**: `set_current_space` before_action in `Madmin::ApplicationController`
- **Tenant Context**: ActsAsTenant automatically scopes all queries to current space
- **Display**: Current space shown in user dropdown menu in header

### Account Type Rules Seeding

#### Automatic Seeding Service
**Service**: `AccountTypeRulesSeeder` (`app/services/account_type_rules_seeder.rb`)
- Automatically seeds 18 standard rules when a new space is created
- Used by both registration controller and rake tasks
- Usage: `AccountTypeRulesSeeder.seed_for_space(space)`

#### Rules Seeded (18 total)
**Trading Rules (10):**
- Daily Loss Limit ($) - currency_amount (default: $2000)
- Max Total Loss ($) - currency_amount (default: $4000)
- Profit Target (%) - percentage (default: 10%)
- Min Trading Days - integer_count (default: 10 days)
- Min Trading Day Amount ($) - currency_amount (default: $100) - Minimum dollar amount required for a day to count as a trading day
- Consistency Rule (%) - percentage (default: 30%)
- Safety Net (%) - percentage (default: 2%)
- Max Position Size (%) - percentage (default: 100%)
- Leverage Limit - integer_count (default: 100)
- Phase 1 Target (%) - percentage (default: 8%)

**Trading Restrictions (2):**
- Weekend Holding - boolean_flag
- News Trading - boolean_flag

**Payout Rules (5):**
- Minimum Payout ($) - currency_amount
- Payout Frequency (days) - integer_count
- Profit Split (%) - percentage
- First Payout Wait (days) - integer_count
- Min Trading Days (Payout) - integer_count

**Payout Restrictions (1):**
- KYC Required - boolean_flag

#### Rake Tasks
```bash
# Seed account type rules for all existing spaces
rake seed:account_type_rules

# Backfill Min Trading Day Amount ($) rule to all existing spaces
rake data:backfill_min_trading_day_amount
```

### Working with Spaces

#### Setting Tenant Context
```ruby
# In controllers (automatic via before_action)
current_space # Returns the current tenant

# Manual tenant switching
ActsAsTenant.with_tenant(space) do
  # All queries within this block are scoped to the space
  Firm.all # Only returns firms in this space
end

# Bypass tenant scoping (use with caution!)
ActsAsTenant.without_tenant do
  Firm.all # Returns ALL firms across all spaces
end
```

#### User Space Helpers
```ruby
current_user.spaces           # All spaces user belongs to
current_user.active_spaces    # Only active spaces
current_user.membership_in(space)  # Get membership for a space
membership.can_manage?        # Check if user can manage space (owner/admin)
```

### Space Display
- **Location**: User dropdown menu in header
- **Format**: Space icon + space name
- **Non-interactive**: Display only (no switching in current implementation)
- **Routes**: All space management routes removed for simplicity

### Data Isolation
- **Automatic**: ActsAsTenant ensures all queries are scoped to current space
- **Security**: Users can only access data within spaces they're members of
- **Foreign Keys**: All multi-tenant models have `space_id` with NOT NULL constraint
- **Unique Constraints**: Most uniqueness validations scoped to space (e.g., `unique: { scope: :space_id }`)

### Important Notes
- Always work within a tenant context when dealing with scoped models
- Use `ActsAsTenant.without_tenant` only for system-level operations
- Space membership determines access - check `current_user.spaces` includes the space
- Rule seeding happens automatically on signup - no manual intervention needed
