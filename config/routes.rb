Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "leads#index"

  resources :contacts, except: [ :show ]
  resources :leads, except: [ :show ] do
    member do
      patch :move
    end
  end
  resources :templates, except: [ :show ]
  resources :categories, only: [ :create ]

  namespace :api do
    namespace :v1 do
      get "openapi.json", to: "base#openapi", as: :openapi
      resources :contacts
      resources :leads
      resources :categories
      resources :templates
    end
  end
end
