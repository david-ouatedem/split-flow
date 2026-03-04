Rails.application.routes.draw do
  devise_for :users

  root "pages#home"

  get "dashboard", to: "dashboard#show"

  resource :profile, only: [ :show, :edit, :update ]

  get "up" => "rails/health#show", as: :rails_health_check
end
