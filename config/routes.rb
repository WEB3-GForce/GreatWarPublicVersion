Rails.application.routes.draw do

  resources :gamas
  
  get 'sessions/new'

  get 'users/new'

  get 'users/show'

  root 'static_pages#home'

  match '/join/:id', to: 'gamas#join', via: [:put]
  match '/leave/:id', to: 'gamas#leave', via: [:put]

  get 'play'    => 'static_pages#play'
  get 'help'    => 'static_pages#help'
  get 'about'   => 'static_pages#about'
  get 'contact' => 'static_pages#contact'
  get 'lobby'   => 'static_pages#lobby'
  get 'all'     => 'users#all'
  get 'signup'  => 'users#new'
  get 'login'   => 'sessions#new'
  post 'login'  => 'sessions#create'
  delete 'logout'=> 'sessions#destroy'
  resources :users
end
