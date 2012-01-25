OsProtectRor320::Application.routes.draw do
  resources :groups

  resources :sessions
  get "login" => "sessions#new", :as => "login"
  get "logout" => "sessions#destroy", :as => "logout"

  resources :password_resets

  resources :sensors, :only => [:index, :edit, :update]

  get "pulse" => "dashboard#index", :as => "pulse"
  get "user_setup_required" => "dashboard#user_setup_required", :as => "user_setup_required"

  resources :incidents

  resources :users

  resources :groups

  resources :events, :only => [:index, :show, :create, :create_pdf]
  get "home" => "events#index", :as => "home"
  post "events_pdf" => "events#create_pdf", :as => "events_pdf"
  root :to => "events#index"
end
