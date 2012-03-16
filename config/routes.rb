Rubydama01::Application.routes.draw do

  root :to => 'home#index'

  resources :media,
            :path => '',
            :only => [:show, :edit],
            :constraints => { :id => /[a-zA-Z0-9_\-]+/ } do
    get :talk, :on => :member
  end

  [:pages].each do |res|
    resources res do
      get :talk, :on => :member
    end
  end

end
