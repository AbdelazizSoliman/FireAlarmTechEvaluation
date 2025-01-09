Rails.application.routes.draw do

  resources :suppliers do 
    collection do
      get :search
    end
  end


  # resources :projects do
  #   member do
  #     get :download_excel
  #   end
  # end

 
  resources :projects do
    resources :systems, only: [:index, :show] do
      resources :subsystems do
        resources :fire_alarm_control_panels, only: [:new, :create, :edit, :update]
      end
    end
  end
  


  devise_for :users

  namespace :api do
    namespace :supplier do
      post 'register', to: 'suppliers#register'
      post 'login', to: 'sessions#create'
      get  '/profile', to: 'sessions#profile'

    end
  end

  namespace :api do
    resources :notifications, only: [:index, :update]
  end

  resources :notifications, only: [] do
    member do
      post :approve
      post :reject
      get :approve
      get :reject
    end
  end

  # namespace :supplier do
  #   get 'all', to: 'suppliers#index'
  #   post 'register', to: 'suppliers#register'
  # end
  
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
   get 'projects/download_excel', to: 'projects#download_excel', as: 'download_excel'

  # Defines the root path route ("/")
   root "pages#index"
end
