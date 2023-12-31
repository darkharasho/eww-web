Rails.application.routes.draw do
  # devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  authenticated :user do
    root :to => 'guilds#index', as: :authenticated_root
  end
  root to: "home#index"

  resources :guilds, only: [:index, :show]
  resources :guilds, param: :id
  resources :configs, only: [:edit, :update]

  post '/set_timezone', to: 'users#set_timezone'

  get 'auth/:provider/callback', to: 'sessions#create'
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }

  devise_scope :user do
    get 'sign_in', :to => 'devise/sessions#new'
    get 'sign_out', :to => 'devise/sessions#destroy'
  end
end
