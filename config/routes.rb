Rails.application.routes.draw do
  resources :themes
  mount Hyperstack::Engine => '/hyperstack'
  get '/', to: 'hyperstack#app'
  post '/compile_css', action: :compile_css, controller: 'application'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
