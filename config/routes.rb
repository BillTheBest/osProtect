class AdminRestriction
  def matches?(request)
    # user_id = request.env['rack.session'][:user_id]
    auth_token = request.env['rack.request.cookie_hash']['auth_token']
    user = User.find_by_auth_token(auth_token)
    user && user.role?(:admin)
  end
end

OsProtectRor320::Application.routes.draw do
  mount Resque::Server => '/resque', :constraints => AdminRestriction.new

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

  resources :notifications
  resources :notification_results, :only => [:index, :show, :destroy]

  resources :reports

  resources :pdfs, :only => [:index, :show, :destroy]

  resources :events, :only => [:index, :show, :create, :create_pdf]
  get "home" => "events#index", :as => "home"
  post "events_pdf" => "events#create_pdf", :as => "events_pdf"
  root :to => "events#index"
end
