Rails.application.routes.draw do
  # Suppliers routes
  resources :suppliers do 
    collection do
      get :search
    end
    member do
      post :set_membership_and_approve  # Handle membership and permissions, then approve
    end
  end

  # Nested Routes for Projects, Systems, and Subsystems
  resources :projects do
    resources :systems, only: [:index, :show, :new, :create]
  end
  

  # Standalone Routes for Systems and Subsystems
  resources :systems, only: [:index, :show, :new, :create]

  resources :subsystems, only: [:index, :show, :new, :create] do
    member do
      get :assign
      post :assign_supplier
    end
  end
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
  resources :notifications, only: [:index] do
    member do
      get :manage_membership # For membership form
      post :approve_supplier  # To handle approval
      post :reject_supplier   # To handle rejection
    end
  end
  # Health check route
  get "up" => "rails/health#show", as: :rails_health_check

  # Excel download route
  get 'projects/download_excel', to: 'projects#download_excel', as: 'download_excel'

  # Root route
  root "pages#index"
end
