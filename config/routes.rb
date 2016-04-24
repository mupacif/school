Rails.application.routes.draw do
  devise_for :users
  root 'pages#home'

  resources :exercises, only: [:index, :show], param: :name
  resources :users

  # Webhooks
  match '/webhooks/update_exercises', via: [:get, :post], :to => 'webhooks#update_exercises'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # Serve websocket cable requests in-process
  # mount ActionCable.server => '/cable'
end
