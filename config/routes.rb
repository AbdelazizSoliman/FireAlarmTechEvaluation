Rails.application.routes.draw do
  # Suppliers routes
  resources :suppliers do 
    collection do
      get :search
    end
  end

  # Nested Routes for Projects, Systems, and Subsystems
  resources :projects do
    resources :systems do
      resources :subsystems do
        resources :fire_alarm_control_panels, only: [:new, :create, :edit, :update, :index]
        member do
          get :assign  # Assign subsystem to a supplier
          post :assign_supplier  # Handle assignment submission
        end
      end
    end
  end

  # Standalone Routes for Systems and Subsystems
  resources :systems, only: [:index, :show]
  resources :subsystems, only: [:index, :show]

  # Devise routes for user authentication
  devise_for :users

  # API namespace
  namespace :api do
    namespace :supplier do
      post 'register', to: 'suppliers#register'
      post 'login', to: 'sessions#create'
      get  '/profile', to: 'sessions#profile'
    end

    resources :notifications, only: [:index, :update]
  end

  # Notifications routes
  resources :notifications, only: [] do
    member do
      post :approve
      post :reject
      get :approve
      get :reject
    end
  end

  # Health check route
  get "up" => "rails/health#show", as: :rails_health_check

  # Excel download route
  get 'projects/download_excel', to: 'projects#download_excel', as: 'download_excel'

  # Root route
  root "pages#index"
end
