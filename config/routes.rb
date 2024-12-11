Rails.application.routes.draw do
  devise_for :users, :controllers => { omniauth_callbacks: "omniauth_callbacks" }

  root "home#index"

  get "up" => "rails/health#show", as: :rails_health_check

  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  resources :organizations, only: %i[index create show]
  resources :projects, only: %i[create show]
  resources :reports, only: %i[] do
    member do
      get :bundled_html, action: :bundled_html
      get "bundled_html/*path", action: :bundled_html
    end
  end


  namespace :api do
    resources :reports, only: %i[] do
      collection do
        post :simplecov
      end
    end
  end
end
