Rubydama01::Application.routes.draw do

  root :to => 'home#index'

  resources :media,
            :path => '',
            :only => [:show, :edit, :update], #no :new, :create
            :constraints => { :id => /[a-zA-Z0-9_\-]+/ } do
    get :talk, :on => :member
    post :create, :on => :member
  end

  match ":context/:id" => "media#show"

end
