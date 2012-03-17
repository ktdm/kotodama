Rubydama01::Application.routes.draw do

  root :to => 'home#index'

  [:pages].each do |res|
    resources res do
      get :talk, :on => :member
    end
  end

  resources :media,
            :path => '',
            :only => [:show, :edit, :update],
            :constraints => { :id => /[a-zA-Z0-9_\-]+/ } do
    get :talk, :on => :member
  end

end
