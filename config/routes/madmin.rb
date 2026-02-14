# frozen_string_literal: true

# Below are the routes for madmin
authenticate :user do
  namespace :madmin do
    get "dashboard", to: "dashboard#index"
    get "dashboard/day/:date", to: "dashboard#day", as: :dashboard_day
    resources :rule_violations
    resources :trades
    resources :users
    resources :accounts
    resources :account_balances
    resources :account_rules
    resources :expenses
    resources :payouts
    resources :firms do
      resources :account_types, only: [:show, :new, :create, :edit, :update, :destroy]
    end
    resources :firm_rules
    resources :rules
    resources :quick_trades, only: [:new, :create]
    root to: "admin_dashboard#show"
  end
end
