Rails.application.routes.draw do
  devise_for :users

  authenticated :user do
    root "dashboard#index", as: :authenticated_root
  end

  # Default root (used when signed out, and provides the `root_path` helper).
  root "pages#landing"

  get "dashboard", to: "dashboard#index"

  resource :profile, only: %i[show edit update], controller: "profiles"

  resources :clients do
    member { get :history }
  end

  resources :projects

  resources :invoices do
    member do
      get   :pdf
      patch :mark_sent
      post  :send_email
      patch :duplicate
    end
    resources :payments, only: %i[new create destroy], shallow: true
    # Adds time entries / line items helpers
    post :import_time, on: :member
  end

  resources :expenses
  resources :time_entries

  namespace :reports do
    get :revenue
    get :clients
    get :profitability
    get :tax
  end
  get "reports", to: "reports#index"

  # Stripe online payments
  resources :checkouts, only: %i[create] do
    collection do
      get :success
      get :cancel
    end
  end
  post "stripe/webhook", to: "stripe_webhooks#create"

  # Public-facing invoice payment page (token based)
  get "pay/:token", to: "public_invoices#show", as: :public_invoice

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check
end
