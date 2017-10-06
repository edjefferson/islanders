Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'pages#index'
  resources :artists
  resources :tracks
  resources :episodes
  resources :categories
  resources :books
  resources :luxuries

  get "/index", :to => 'pages#index'
end
