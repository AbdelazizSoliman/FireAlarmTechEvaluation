Rails.application.routes.draw do
  # ✅ API namespace for suppliers
  namespace :api do
    namespace :supplier do
      resources :suppliers, only: [:create, :index, :show]
      resources :projects, only: [:index] 
      resources :project_scopes, only: [:index] 
      resources :systems, only: [:index] 
      resources :subsystems, only: [:index] # ✅ Removed duplicate

      post 'register', to: 'suppliers#register'
      post 'login', to: 'sessions#create'
      get 'profile', to: 'sessions#profile'
      get 'dashboard', to: 'suppliers#dashboard'
      get 'supplier_data', to: 'supplier_data#index'
    end

    # Nested Routes for Projects, Systems, and Subsystems within API namespace
    resources :projects do
      resources :project_scopes do
        resources :systems do
          resources :subsystems, only: [] do
            post :submit_all, on: :member
            get :submitted_data, on: :member
            member do
              put :update_submission
            end
          end
        end
      end
    end

    resources :notifications, only: [:index, :update] do
      member do
        post :approve_supplier
        post :reject_supplier
      end
    end
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

  # ✅ Comparisons (Apple to Apple Comparison)
  resources :comparisons, only: [:index] do
    collection do
      post :generate   # Generate Apple to Apple Comparison
      get :export      # Export Apple to Apple Comparison to Excel (optional)
    end
  end

  # ✅ Supplier Routes (Non-API)
  resources :suppliers do
    collection do
      get :search
      get 'dashboard', to: 'suppliers#dashboard'
    end
    member do
      post :set_membership_and_approve  # ✅ Handle membership and approval process
    end
  end

  # ✅ Notifications (Non-API)
  resources :notifications do
    member do
      get :manage_membership
      post :approve_supplier
      post :reject_supplier
    end
  end

  resources :requirements_data, only: [:index] do
    collection do
      post :update
      get :download
    end
  end

  # ✅ Reports Routes
 # Reports Routes
 resources :reports, only: [:index] do
  collection do
    get :evaluation_tech_report
    get :evaluation_data # Show evaluation data for a supplier and subsystem
    get :generate_evaluation_report # Generate and download the evaluation report
    get :evaluation_report  # Generate Evaluation/Tech Report
    get :recommendation  # Generate Recommendation
    get :apple_to_apple_comparison  # Generate Apple to Apple Comparison
    get :generate_comparison_report
    get :sow  # Generate/Determine SOW between Suppliers & Installation Contractor
    get :missing_items  # Generate Missing Items
    get :differences  # Generate Differences between Bidders
    get :interfaces  # Generate Interfaces among Systems
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
