Rails.application.routes.draw do
  
  scope 'admin' do
    get "/", to: "posts#index"
    resources :posts
  end

  root "blog#index"
end
