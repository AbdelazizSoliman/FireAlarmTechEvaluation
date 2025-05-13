# config/routes.rb
Rails.application.routes.draw do

  get  'upload_excel',        to: 'dynamic_tables#upload_excel'
    post 'preview_excel',       to: 'dynamic_tables#preview_excel'
    post 'import_excel_tables', to: 'dynamic_tables#import_excel_tables'
  namespace :admin do
    resources :submissions, only: [:index, :show]
  end

  # ✅ API namespace for suppliers
  namespace :api do
    get  '/subsystems/:subsystem_id/table_order',       to: 'dynamic_tables#table_order'
    get  '/subsystems/:subsystem_id/table_definitions', to: 'dynamic_tables#table_definitions'
    post '/subsystems/:subsystem_id/save_all',          to: 'dynamic_tables#save_all'
    
    namespace :supplier do
      resources :suppliers,      only: [:create, :index, :show]
      resources :projects,       only: [:index]
      resources :project_scopes, only: [:index]
      resources :systems,        only: [:index]
      resources :subsystems,     only: [:index]
      get  'subsystem_tables', to: 'suppliers#subsystem_tables'
      post 'register',         to: 'suppliers#register'
      post 'login',            to: 'sessions#create'
      get  'profile',          to: 'sessions#profile'
      get  'dashboard',        to: 'suppliers#dashboard'
      get  'supplier_data',    to: 'supplier_data#index'
    end

    # Nested routes for Projects → ProjectScopes → Systems → Subsystems
    resources :projects do
      resources :project_scopes do
        resources :systems do
          resources :subsystems, only: [] do
            post :submit_all,      on: :member
            get  :submitted_data,  on: :member
            put  :update_submission, on: :member
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

    # Dynamic‐table endpoints under /api/subsystems/:id
    # resources :subsystems, only: [] do
    #   member do
    #     get  :table_order        # GET  /api/subsystems/:id/table_order
    #     get  :table_definitions  # GET  /api/subsystems/:id/table_definitions
    #     post :save_all           # POST /api/subsystems/:id/save_all
    #   end
    # end

    resources :sub_tables, only: [:index]

    # Additional dynamic‐table routes
    get   '/dynamic_tables/:table_name',     to: 'dynamic_tables#index'
    patch '/dynamic_tables/:table_name/:id', to: 'dynamic_tables#update'
    get   '/table_metadata/:table_name',     to: 'dynamic_tables#table_metadata'
    post  '/save_data/:table_name',          to: 'dynamic_tables#save_data'
  end

  # -------------------------
  # Non‐API (legacy) routes
  # -------------------------
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

  resources :comparisons, only: [:index] do
    collection do
      post :generate
      get  :export
    end
  end

  resources :suppliers do
    collection do
      get :search
      get 'dashboard', to: 'suppliers#dashboard'
    end
    member do
      post :set_membership_and_approve
    end
  end

  resources :notifications do
    member do
      get  :manage_membership
      post :approve_supplier
      post :reject_supplier
    end
  end

  resources :requirements_data, only: [:index] do
    collection do
      post :update
      get  :download
    end
  end

  resources :reports, only: [:index] do
    collection do
      get :evaluation_tech_report
      get :evaluation_data
      get :generate_evaluation_report
      get :evaluation_result
      get :recommendation

      get :generate_excel_report

      get :apple_to_apple_comparison
      get :show_comparison_report
      get :generate_comparison_report

      get :sow
      get :missing_items
      get :differences
      get :interfaces
    end
  end

  resources :evaluation_results, only: [:index] do
    collection do
      post :evaluate     # kicks off the service
      get  :download     # streams Excel
    end
  end

  resources :project_scopes, only: [:index, :show, :new, :create]
  resources :systems,        only: [:index, :show, :new, :create]
  resources :subsystems,     only: [:index, :show, :new, :create]

  get  'up',                           to: 'rails/health#show',           as: :rails_health_check
  get  'projects/download_excel',      to: 'projects#download_excel',      as: :download_excel
  get  'reports/generate_excel_report',to: 'reports#generate_excel_report',as: :generate_excel_report

  devise_for :users

  authenticated :user do
    root to: 'dashboard#index', as: :authenticated_root
  end
  devise_scope :user do
    root to: 'devise/sessions#new', as: :unauthenticated_root
  end

  # Admin panel routes
  
  get   '/admin',                           to: 'dynamic_tables#admin'
  post  '/admin/add_column',                to: 'dynamic_tables#add_column'
  post  '/admin/create_table',              to: 'dynamic_tables#create_table'
  post  '/admin/create_multiple_tables',    to: 'dynamic_tables#create_multiple_tables'
  post  '/admin/create_multiple_sub_tables',to: 'dynamic_tables#create_multiple_sub_tables'
  post  '/admin/create_multiple_features',  to: 'dynamic_tables#create_multiple_features'
  post  '/admin/move_table',                to: 'dynamic_tables#move_table',       as: :move_table_dynamic_tables
  get   '/admin/sub_tables',                to: 'dynamic_tables#sub_tables'
  get   '/admin/check_table_name',          to: 'dynamic_tables#check_table_name'
  get   '/dynamic_tables/:table_name/columns/:column_name/edit_metadata',
        to: 'dynamic_tables#edit_metadata',   as: :edit_metadata_dynamic_tables
  patch '/dynamic_tables/:table_name/columns/:column_name/update_metadata',
        to: 'dynamic_tables#update_metadata', as: :update_metadata_dynamic_tables
  get   '/dynamic_tables/:table_name',      to: 'dynamic_tables#show',           as: :dynamic_table
  get   '/subsystems/:subsystem_id/:table_name',
        to: 'dynamic_tables#show_with_subsystem',                      as: :subsystem_dynamic_table
end
