Rails.application.routes.draw do
  resources :payments do
    collection do
      get :success
      get :cancel
      post :notify
      get :close_popup
    end
  end
end
