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
end
