Rails.application.routes.draw do
  devise_for :users, :controllers => { omniauth_callbacks: "omniauth_callbacks" } do
    # post 'sign_out', :to => 'devise/sessions#destroy', :as => :destroy_user_session
  end
  # devise_scope :user do
  #   get 'sign_in', :to => 'devise/sessions#new', :as => :new_user_session
  #   get 'sign_out', :to => 'devise/sessions#destroy', :as => :destroy_user_session
  # end

  root "home#index"

  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  resources :reports, only: %i[] do
    member do
      get :bundled_html, action: :bundled_html
      get "bundled_html/*path", action: :bundled_html
    end
  end
end
