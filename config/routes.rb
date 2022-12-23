Rails.application.routes.draw do
  resources :comments
  resources :tags
  resources :posts
  resources :users
  post "/login", to: "application#login"
  get "/authenticate", to: "application#authenticate_request"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
