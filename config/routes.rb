Rubydama01::Application.routes.draw do

  root :to => 'media#show'

  resources :media,
            :path => '',
            :only => [:show, :edit, :update], #no :new, :create
            :constraints => { :id => /[a-zA-Z0-9_\-]+/ } do
    get :talk, :on => :member
    post :create, :on => :member
  end

  get ":context/:id" => "media#show",
       :constraints => { :context => /[a-zA-Z0-9_\-]+/, :id => /[a-zA-Z0-9_\-]+/ }

end
