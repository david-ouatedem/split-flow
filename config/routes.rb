Rails.application.routes.draw do
  devise_for :users

  root "pages#home"

  get "dashboard", to: "dashboard#show"

  resource :profile, only: [ :show, :edit, :update ]

  resources :projects do
    resources :collaborations, only: [ :create, :destroy ] do
      member do
        patch :accept
        patch :decline
      end
    end
  end

  get "invitations", to: "collaborations#invitations"

  get "up" => "rails/health#show", as: :rails_health_check
end
