Rails.application.routes.draw do
  devise_for :users, controllers: { invitations: "users/invitations" }

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

    resources :project_files, only: [ :create, :destroy ], path: "files" do
      collection do
        get :download_all
      end
    end

    resource :split_agreement, only: [ :show, :new, :create, :edit, :update ], path: "splits" do
      member do
        patch :propose
        get :export_pdf
      end

      resources :split_entries, only: [] do
        member do
          patch :approve
        end
      end
    end
  end

  get "invitations", to: "collaborations#invitations"

  # Public split agreement verification (no auth required)
  get "verify/:verification_token", to: "split_agreements#verify", as: :verify_split_agreement

  get "up" => "rails/health#show", as: :rails_health_check
end
