Rails.application.routes.draw do
  resources :auth_tokens, format: :json, only: [:create] do
    collection do
      get :validate
    end
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
