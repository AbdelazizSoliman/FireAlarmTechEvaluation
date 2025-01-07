Rails.application.routes.draw do

  resources :suppliers do 
    collection do
      get :search
    end
  end

  
  resources :products
  resources :fire_alarm_control_panels
  resources :graphic_systems  
  resources :projects do
    member do
      get :download_excel
    end
  end

  devise_for :users

  namespace :api do
    namespace :supplier do
      post 'register', to: 'suppliers#register'
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
