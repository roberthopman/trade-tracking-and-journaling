# frozen_string_literal: true

source "https://rubygems.org"

ruby file: ".ruby-version"

gem "bootsnap", require: false
gem "devise"
gem "good_migrations"
gem "kamal", require: false
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"
gem "rails", "~> 8.0.2", ">= 8.0.2.1"
gem "solid_cache"
gem "solid_queue"
gem "stimulus-rails"
gem "thruster", require: false
gem "turbo-rails"
gem "tzinfo-data", platforms: %i[windows jruby]
gem "vite_rails", "~> 3.0"

group :development, :test do
  gem "brakeman", require: false
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"
  gem "dotenv", ">= 3.0"
  gem "factory_bot_rails"
end

group :development do
  gem "annotaterb"
  gem "bundler-audit", require: false
  gem "erb_lint", require: false
  gem "letter_opener"
  gem "pgcli-rails"
  gem "rack-mini-profiler"
  gem "rubocop", require: false
  gem "rubocop-capybara", require: false
  gem "rubocop-factory_bot", require: false
  gem "rubocop-minitest", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-rails", require: false
  gem "web-console"
end

group :test do
  gem "capybara", require: false
  gem "capybara-lockstep", require: false
  gem "selenium-webdriver", require: false
end

gem "acts_as_tenant"
gem "madmin", "~> 2.1"
gem "pretender"
