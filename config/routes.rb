Drinkboard::Application.routes.draw do

  root                         to: 'sessions#new'
  resources :sessions,       only: [:new, :create, :destroy]
  match '/signin',             to: 'sessions#new',                via: :get
  match '/signout',            to: 'sessions#destroy'
  match '/forgot_password',    to: 'sessions#forgot_password',    via: [:get, :post]
  match '/reset_password',     to: 'sessions#forgot_password',    via:  :get
  match '/enter_new_password', to: 'sessions#enter_new_password', via: [:get, :put]
  match '/valid_token',        to: 'sessions#validate_token',     via: :get
  match '/change_password/:id', to: 'sessions#change_password',    via: :post

  match '/admin',              to: 'admin#show'        ,           via: :get
  match '/admin/test_emails',  to: 'admin#test_emails' ,           via: :get
  match '/admin/run_tests',    to: 'admin#run_tests'   ,           via: :get
  match '/push/register',      to: 'admin#push_register' ,         via: :get
  match '/push/notify',        to: 'admin#push_notify'   ,         via: :get

  match "/invite/email_confirmed"     , to: "invite#email_confirmed", via: :get
  match "/invite/error"               , to: "invite#error",           via: :get
  match "/invite/gift/:id"            , to: "invite#show",            via: :get
  match "/invite/person/:id"          , to: "invite#invite",          via: :get
  match "/webview(/:template(/:var1))", to: "invite#display_email",   via: :get

  match "/confirm_email(/:email(/:user))", to: "users#confirm_email", via: :get

  mount Resque::Server, :at => "/resque"

  resources :users do
    member do
      get  :following, :followers
      get  :servercode
      get  :crop
      get  :change_public_status
      post :update_avatar
      get  :de_activate
      get  :destroy_gifts
    end
  end

  resources :providers do
    member do
      get :add_photo
      post :upload_photo
      get :brands
      get :brand
      get :building
      get :menu
      get :staff
      post :update_item
      post :delete_item
      get  :compile_menu
      get  :add_member
      get :menu_item
      get :upload_menu
      get :remove_menu_item
      get :coming_soon
      get :de_activate
      get :create_merchant_tools
      get :members
      get :add_employee
      get :remove_employee
      get 'invite_employee'
      post 'invite_employee'
    end
  end

  resources :brands do
    member do
      get :add_photo
      post :upload_photo
      get :merchants
      get :brand_merchant
      get :building_merchant
    end
  end

  match "/merchants/:id/employee/:eid/remove"  => "merchants#remove_employee" , via: :get
  resources :menus
  resources :merchants do
    member do
      get  :todays_credits
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
      get  :menu_builder

    end
  end

  resources :gifts,       only: [:index, :show]

    ###  mobile app routes
  match 'app/create_account',   to: 'iphone#create_account',   via: :post
  match 'app/login',            to: 'iphone#login',            via: :post
  match 'app/login_social',     to: 'iphone#login_social',     via: :post
  match 'app/update',           to: 'app#relays',              via: :post
  match 'app/gifts',            to: 'iphone#gifts',            via: :post
  match 'app/update_user',      to: 'app#update_user',         via: :post
  match 'app/gifts_array',      to: 'app#gifts',               via: :post
  match 'app/archive',          to: 'iphone#archive',          via: :post
  match 'app/brands',           to: 'app#brands',              via: :post
  match 'app/brand_merchants',  to: 'app#brand_merchants',     via: :post
  match 'app/providers',        to: 'app#providers',           via: :post
  match 'app/get_providers',    to: 'app#providers',           via: :get
  match 'app/employees',        to: 'app#create_redeem_emps',  via: :post
  match 'app/redeem',           to: 'app#create_redeem',       via: :post
  match 'app/complete_order',   to: 'app#create_order_emp',    via: :post
  match 'app/order_confirm',    to: 'app#create_order',        via: :post
  match 'app/menu_v2',          to: 'app#menu_v2',             via: :post
  match 'app/questions',        to: 'app#questions',           via: :post
  match 'app/others_questions', to: 'app#others_questions',    via: :post
  match 'app/transactions',     to: 'app#transactions',        via: :post
  match 'app/user_activity',    to: 'app#user_activity',       via: :post
  match 'app/users_array',      to: 'app#drinkboard_users',    via: :post
  match 'app/create_gift',      to: 'app#create_gift',         via: :post
  match 'app/photo',            to: 'iphone#update_photo',     via: :post
  match 'app/orders',           to: 'app#orders',              via: :post
  match 'app/merchant_redeem',  to: 'app#merchant_redeem',     via: :post
  match 'app/reset_password',   to: 'app#reset_password',      via: :post
  match 'app/get_settings',     to: 'app#get_settings',        via: :post
  match 'app/save_settings',    to: 'app#save_settings',       via: :post
  match 'app/m_save_settings',  to: 'app#save_settings_m',     via: :post
  match 'app/regift',           to: 'iphone#regift',           via: :post
    ## test new data methods routes
  match 'app/new_pic',          to: 'app#providers_short_ph_url', via: :post
  match 'app/cities_app',       to: 'iphone#cities'

    ## credit card routes
  match 'app/cards',            to: 'app#get_cards',           via: :post
  match 'app/add_card',         to: 'app#add_card',            via: :post
  match 'app/delete_card',      to: 'app#delete_card',         via: :post

    ### deprecated app routes
  match 'app/menu',             to: 'app#menu',                via: :post

  match 'app/activity',         to: 'iphone#activity',         via: :post
  match 'app/locations',        to: 'iphone#locations',        via: :post
  match 'app/out',              to: 'iphone#going_out',        via: :post
  match 'app/active',           to: 'iphone#active_orders',    via: :post
  match 'app/completed',        to: 'iphone#completed_orders', via: :post
  match 'app/buys',             to: 'iphone#buys',             via: :post
  match 'app/buy_gift',         to: 'iphone#create_gift',      via: :post
  match 'app/past_gifts',       to: 'app#past_gifts',          via: :post

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

  ## SERVICES ROUTES (app . mdot)
  # namespace :app, defaults: { format: 'json' } do
  #   namespace :v2 do
  #     post 'regift',  to: 'apple#regift'
  #     post 'menu',    to: 'apple#menu'
  #   end
  # end

  ## ADMIN TOOLS routes for API
  namespace :admt, defaults: { format: 'json' } do
    namespace :v1 do
      post 'add_key_app',       to: 'admin_tools#add_key'
      post 'get_gifts',         to: 'admin_tools#gifts'
      post 'get_gift',          to: 'admin_tools#gift'
      post 'get_app_users',     to: 'admin_tools#users'
      post 'get_app_user',      to: 'admin_tools#user'
      post 'user_and_gifts',    to: 'admin_tools#user_and_gifts'
      post 'update_user',       to: 'admin_tools#update_user'
      post 'get_brands',        to: 'admin_tools#brands'
      post 'get_brand',         to: 'admin_tools#brand'
      post 'create_brand',      to: 'admin_tools#create_brand'
      post 'update_brand',      to: 'admin_tools#update_brand'
      post 'de_activate_brand', to: 'admin_tools#de_activate_brand'
      post 'associate',         to: 'admin_tools#associate'
      post 'de_associate',      to: 'admin_tools#de_associate'
      post 'providers',         to: 'admin_tools#providers'
      post 'go_live',           to: 'admin_tools#go_live'
      post 'de_activate_user',  to: 'admin_tools#de_activate_user'
      post 'destroy_all_gifts', to: 'admin_tools#destroy_all_gifts'
      post 'destroy_user',      to: 'admin_tools#destroy_user'
      post 'de_activate_merchant', to: 'admin_tools#de_activate_merchant'
      post 'cancel',            to: 'admin_tools#cancel'
      post 'orders',            to: 'admin_tools#orders'
      post 'unsettled',         to: 'admin_tools#unsettled'
      post 'settled',           to: 'admin_tools#settled'
    end
  end

  ## MERCHANT TOOLS routes for API
  namespace :mt, defaults: { format: 'json' } do
    namespace :v1 do
      post 'create_merchant', to: 'merchant_tools#create'
      post 'orders',          to: 'merchant_tools#orders'
      post 'order',           to: 'merchant_tools#order'
      post 'compile_menu',    to: 'merchant_tools#compile_menu'
      post 'update_photo',    to: 'merchant_tools#update_photo'
      post 'summary_range',   to: 'merchant_tools#summary_range'
      post 'summary_report',  to: 'merchant_tools#summary_report'
    end
  end

    ## merchant tools routes
  match 'mt/user_login',           to: 'merchants#login',        via: :post
  match 'mt/merchant_login',       to: 'merchants#authorize',    via: :post
  match 'mt/menu',                 to: 'merchants#menu',         via: :post
  match 'mt/reports',              to: 'merchants#reports',      via: :post
  match 'mt/employees',            to: 'merchants#employees',    via: :post
  match 'mt/finances',             to: 'merchants#finances',     via: :post
  match 'mt/deactivate_employee',  to: 'merchants#deactivate_employee', via: :post
  match 'mt/email_invite',         to: 'merchants#email_invite',        via: :post
  match 'mt/compile_menu',         to: 'merchants#compile_menu', via: :post

end
