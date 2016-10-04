Rails.application.routes.draw do
  get "/oauth2callback", to: "tools#update"
  get "/signin", to: "tools#index"
  post "/signin", to: "tools#index"

  root "tools#index"
  resources :tools
end
