# frozen_string_literal: true

class AccountTypeRulesSeeder
  def self.seed_for_space(space)
    new(space).seed
  end

  def initialize(space)
    @space = space
  end

  def seed
    TradingRulesSeeder.seed_for_space(@space)
    PayoutRulesSeeder.seed_for_space(@space)
  end
end
