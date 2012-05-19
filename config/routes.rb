Rubydama01::Application.routes.draw do

  root :to => 'media#show'

  #get "run" => 'media#run'

  resources :media,
            :path => '',
            :only => [:show, :edit, :update],
            :constraints => { :id => /[a-zA-Z0-9_\-]+/ } do
    get :talk, :on => :member
    post :create, :on => :member
  end

  get ":context/:id" => "media#show",
       :constraints => { :context => /[a-zA-Z0-9_\-]+/, :id => /[a-zA-Z0-9_\-]+/ }

end
