Rails.application.routes.draw do

  namespace :admin do
    resources :submissions, only: [:index, :show]
  end
  
  # ✅ API namespace for suppliers
  namespace :api do
    post 'save_all', to: 'dynamic_tables#save_all'

    namespace :supplier do
      resources :suppliers, only: [:create, :index, :show]
      resources :projects, only: [:index] 
      resources :project_scopes, only: [:index] 
      resources :systems, only: [:index] 
      resources :subsystems, only: [:index] # ✅ Removed duplicate
      get 'subsystem_tables', to: 'suppliers#subsystem_tables'
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

    resources :subsystems, only: [] do
      member do
        get :table_order
      end
    end

      resources :sub_tables, only: [:index]
     # Dynamic Table API Routes
     
      get "/dynamic_tables/:table_name", to: "dynamic_tables#index"
      patch "/dynamic_tables/:table_name/:id", to: "dynamic_tables#update"
      get '/table_metadata/:table_name', to: 'dynamic_tables#table_metadata'
      post '/save_data/:table_name', to: 'dynamic_tables#save_data'
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

 # Reports Routes
  resources :reports, only: [:index] do
    collection do
      get :evaluation_tech_report
      get :evaluation_data # Show evaluation data for a supplier and subsystem
      get :generate_evaluation_report # Generate and download the evaluation report
      get :evaluation_report  # Generate Evaluation/Tech Report
      get :evaluation_result
      get :recommendation  # Generate Recommendation
      get :apple_to_apple_comparison  # Generate Apple to Apple Comparison
      get :show_comparison_report
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

  # ✅ Health check route
  get "up" => "rails/health#show", as: :rails_health_check

  # ✅ Excel download route
  get 'projects/download_excel', to: 'projects#download_excel', as: 'download_excel'
  get 'reports/generate_excel_report', to: 'reports#generate_excel_report', as: 'generate_excel_report'


  devise_for :users

  # Redirect authenticated users to Dashboard
  authenticated :user do
    root to: "dashboard#index", as: :authenticated_root
  end

  # Redirect unauthenticated users to the login page
  devise_scope :user do
    root to: "devise/sessions#new", as: :unauthenticated_root
  end

  get "/admin", to: "dynamic_tables#admin"
  post "/admin/add_column", to: "dynamic_tables#add_column"
  post '/admin/create_table', to: 'dynamic_tables#create_table'
  get '/dynamic_tables/:table_name/columns/:column_name/edit_metadata', to: 'dynamic_tables#edit_metadata', as: 'edit_metadata_dynamic_tables'
  patch '/dynamic_tables/:table_name/columns/:column_name/update_metadata', to: 'dynamic_tables#update_metadata', as: 'update_metadata_dynamic_tables'
  get '/dynamic_tables/:table_name', to: 'dynamic_tables#show', as: 'dynamic_table'
  get '/subsystems/:subsystem_id/:table_name', to: 'dynamic_tables#show_with_subsystem', as: 'subsystem_dynamic_table'
  post '/admin/create_sub_table', to: 'dynamic_tables#create_multiple_sub_tables'
  post '/admin/create_multiple_tables', to: 'dynamic_tables#create_multiple_tables'
  post '/admin/create_multiple_sub_tables', to: 'dynamic_tables#create_multiple_sub_tables'
  post '/admin/create_multiple_features', to: 'dynamic_tables#create_multiple_features'
  get '/admin/sub_tables', to: 'dynamic_tables#sub_tables'
  get '/table_metadata/:table_name', to: 'dynamic_tables#show'
  post '/admin/move_table', to: 'dynamic_tables#move_table', as: 'move_table_dynamic_tables'
  get '/subsystems/:subsystem_id/ordered_tables', to: 'dynamic_tables#ordered_tables'
  get '/admin/check_table_name', to: 'dynamic_tables#check_table_name'

end
