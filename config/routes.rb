Rails.application.routes.draw do
  # API namespace
  namespace :api do
    namespace :supplier do
      resources :subsystems, only: [:index]
      resources :suppliers, only: [:create, :index, :show]
      resources :projects, only: [:index] # ✅ Fixed route for projects
      resources :project_scopes, only: [:index] # ✅ Fixed route for project scopes
      resources :systems, only: [:index] # ✅ Fixed route for systems
      resources :subsystems, only: [:index] # ✅ Fixed route for subsystems
      post 'register', to: 'suppliers#register'
      post 'login', to: 'sessions#create'
      get '/profile', to: 'sessions#profile'
      get '/dashboard', to: 'suppliers#dashboard'
      get '/supplier_data', to: 'supplier_data#index'
    end

    resources :notifications, only: [:index, :update]
  end

  # ✅ RESTORE EVALUATION SYSTEM & STANDALONE ROUTES
  resources :projects do
    resources :project_scopes do
      resources :systems do
        resources :subsystems do
          post :submit_all, on: :member
          resources :fire_alarm_control_panels, only: [:create, :index]
        end
      end
    end
  end

  # Non-API routes
  resources :suppliers do
    collection do
      get :search
      get 'dashboard', to: 'suppliers#dashboard'
    end
    member do
      post :set_membership_and_approve  # Handle membership and permissions, then approve
    end
  end

  # ✅ Notifications
  resources :notifications, only: [:index, :show] do
    member do
      get :manage_membership
      post :approve_supplier
      post :reject_supplier
    end
  end

  # ✅ Standalone Routes for Systems and Subsystems
  resources :project_scopes, only: [:index, :show, :new, :create]
  resources :systems, only: [:index, :show, :new, :create]
  resources :subsystems, only: [:index, :show, :new, :create]

  # ✅ Devise routes for user authentication
  devise_for :users

  # ✅ Health check route
  get "up" => "rails/health#show", as: :rails_health_check

  # ✅ Excel download route
  get 'projects/download_excel', to: 'projects#download_excel', as: 'download_excel'

  # ✅ Root route
  root "pages#index"
end
