Rails.application.routes.draw do
  # API namespace
  namespace :api do
    namespace :supplier do
      post 'register', to: 'suppliers#register'
      post 'login', to: 'sessions#create'
      get  '/profile', to: 'sessions#profile'
      get '/dashboard', to: 'suppliers#dashboard'
    end

    # Nested Routes for Projects, Systems, and Subsystems within API namespace
    resources :projects do
      resources :project_scopes do
        resources :systems do
          resources :subsystems do
            resources :fire_alarm_control_panels, only: [:create, :index] # Add :index for GET
          end
        end
      end
    end

    resources :notifications, only: [:index, :update]
  end

  resources :projects do
    resources :project_scopes do
      resources :systems do
        resources :subsystems do
          resources :fire_alarm_control_panels, only: [:create, :index] # Add :index for GET
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

  # Notifications routes
  resources :notifications, only: [:index] do
    member do
      get :manage_membership # For membership form
      post :approve_supplier  # To handle approval
      post :reject_supplier   # To handle rejection
    end
  end

  # Standalone Routes for Systems and Subsystems
  resources :project_scopes, only: [:index, :show, :new, :create]

  resources :systems, only: [:index, :show, :new, :create]

  resources :subsystems, only: [:index, :show, :new, :create]
 
  # Devise routes for user authentication
  devise_for :users

  # Health check route
  get "up" => "rails/health#show", as: :rails_health_check

  # Excel download route
  get 'projects/download_excel', to: 'projects#download_excel', as: 'download_excel'

  # Root route
  root "pages#index"
end
