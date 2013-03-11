Drinkboard::Application.routes.draw do
  
  root to: 'users#new'
  resources :brands

  resources :sales
  resources :cards

  match "/invite/email_confirmed" => "invite#email_confirmed"
  match "/invite/error"    => "invite#error"
  match "/invite/:id"      => "invite#show"
  match "/invite"          => "invite#invite_friend"
  match "/webview(/:template(/:var1))"   => "invite#display_email", :via => :get

  
  match '/welcome', to: 'admins#welcome'
  match '/login',   to: 'users#new'
  match '/signup',  to: 'users#new'
  match '/signin',  to: 'sessions#new'
  match '/signout', to: 'sessions#destroy'
  
    ###   basic footer routes
  match '/about',       to: 'home#about'
  match '/contact',     to: 'home#contact'
  match '/home',        to: 'home#index'
  match '/learn',       to: 'home#learn'
  match '/news',        to: 'home#news'  

  resources :gifts do
    collection do
      get  'buy'
      get  'activity'
      get  'browse'
      post 'browse_with_contact'
      post 'browse_with_location'
      post 'choose_from_menu'
      post 'choose_from_contacts'
      post 'bill'
      get  'past'
    end
    member do
      get 'detail'
      get 'completed'
    end
  end
  
  resources :locations
  resources :menus
  resources :menu_strings
  resources :orders
  resources :redeems

  resources :users do 
    member do
      get  :following, :followers
      get  :servercode
      get  :crop
      get  :change_public_status
      post :update_avatar
    end
    collection do
      get  :confirm_email
      get  :reset_password
      post :reset_password
      get  :enter_new_password
      put  :enter_new_password
    end
  end

  resources :employees
  resources :locations
  resources :providers 
  match "/merchants/:id/employee/:eid/remove"   => "merchants#remove_employee"
  
  resources :merchants do
    get 'home'
    member do
      # test routes
      get 'baronVonJovi'
      get 'explorer'
      get  :help
      get  :pos
      get  :menujs
      # end test routes
      get 'past_orders'
      get 'customers'
      get 'orders'
      get 'redeem'
      get  :completed
      get 'staff'
      get 'edit_info'
      get 'edit_photo'
      get 'edit_bank'
      get 'invite_employee'
      post 'invite_employee'
      get 'add_employee'
      get  :add_member
      get 'menu'
      get 'photos'
      post :update_photos
      get 'staff_profile'
      post :update_item
      post :delete_item
      get  :get_cropper
      get  :compile_menu
      get  :menu_builder
    end
  end

  resources :subtle_data


  resources :microposts,    only: [:create, :destroy]
  resources :relationships, only: [:create, :destroy]
  resources :connections, only: [:create, :destroy]
  resources :sessions,    only: [:new, :create, :destroy]
  resources :admins, only: [:new, :create, :destroy]
 
    ###  mobile app routes
  match 'app/create_account',   to: 'iphone#create_account',   via: :post
  match 'app/login',            to: 'iphone#login',            via: :post
  match 'app/login_social',     to: 'iphone#login_social',     via: :post
  match 'app/update',           to: 'app#relays',              via: :post 
  match 'app/gifts',            to: 'iphone#gifts',            via: :post
  match 'app/update_user',      to: 'app#update_user',         via: :post
  match 'app/gifts_array',      to: 'app#gifts',               via: :post
  match 'app/past_gifts',       to: 'app#past_gifts',          via: :post
  match 'app/providers',        to: 'app#providers',           via: :post
  match 'app/get_providers',    to: 'app#providers',           via: :get
  match 'app/employees',        to: 'app#create_redeem',       via: :post
  match 'app/complete_order',   to: 'app#create_order',        via: :post
  match 'app/menu',             to: 'app#menu',                via: :post
  match 'app/questions',        to: 'app#questions',           via: :post
  match 'app/others_questions', to: 'app#others_questions',    via: :post
  match 'app/transactions',     to: 'app#transactions',        via: :post
  match 'app/user_activity',    to: 'app#user_activity',       via: :post
  match 'app/users_array',      to: 'app#drinkboard_users',    via: :post
  match 'app/buy_gift',         to: 'iphone#create_gift',      via: :post
  match 'app/photo',            to: 'iphone#update_photo',     via: :post 
  match 'app/orders',           to: 'app#orders',              via: :post
  match 'app/merchant_redeem',  to: 'app#merchant_redeem',     via: :post
  match 'app/forgot_password',  to: 'app#forgot_password',     via: :post
  match 'app/reset_password',   to: 'app#reset_password',      via: :post
  match 'app/get_settings',     to: 'app#get_settings',       via: :post
  match 'app/save_settings',    to: 'app#save_settings',      via: :post

    ## test new data methods routes
  match 'app/new_pic', to: 'app#providers_short_ph_url', via: :post

    ## credit card routes
  match 'app/cards',            to: 'app#get_cards',           via: :post
  match 'app/add_card',         to: 'app#add_card',            via: :post
  match 'app/delete_card',      to: 'app#delete_card',         via: :post
    ### deprecated app routes
  match 'app/activity',         to: 'iphone#activity',         via: :post
  match 'app/locations',        to: 'iphone#locations',        via: :post
  match 'app/out',              to: 'iphone#going_out',        via: :post 
  match 'app/active',           to: 'iphone#active_orders',    via: :post
  match 'app/completed',        to: 'iphone#completed_orders', via: :post
  match 'app/regift',           to: 'iphone#regift',           via: :post
  match 'app/buys',             to: 'iphone#buys',             via: :post
  
    ### authentication via Facebook & Foursquare
  match '/facebook/oauth',    to: 'oAuth#loginWithFacebook'
  match '/foursquare/oauth',  to: 'oAuth#loginWithFoursquare'
  ###
  
    ### Location resources
  match '/map',               to: 'locations#map'
  match '/map/boundary',      to: 'locations#mapForUserWithinBoundary'
  match '/facebook/checkin',   to: 'locations#validateFacebookSubscription',  via: :get
  match '/facebook/checkin',   to: 'locations#realTimeFacebookUpdate',        via: :post
  match '/foursquare/checkin', to: 'locations#realTimeFoursquareUpdate',      via: :post

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
