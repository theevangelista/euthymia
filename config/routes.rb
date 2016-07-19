# frozen_string_literal: true
Rails.application.routes.draw do
  resources :journals do
    resources :entries
  end
  get '/' => 'home#index', as: :root

  devise_for :users, controllers: { registrations: 'registrations' }
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
