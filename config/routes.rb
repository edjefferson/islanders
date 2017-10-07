Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'pages#index'
  resources :artists
  resources :discs
  resources :episodes
  resources :wiki_categories
  resources :books
  resources :luxuries

  get "/index", :to => 'pages#index'
end
