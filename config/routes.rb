Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :code_reviews, only: [ :create ]
    end
  end
end
