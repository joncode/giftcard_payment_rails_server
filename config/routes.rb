Drinkboard::Application.routes.draw do


#################         iOS app & Mdot V1 API                   /////////////////////////////

    ###  mobile app routes
  match 'app/create_account',   to: 'iphone#create_account',   via: :post
  match 'app/login',            to: 'iphone#login',            via: :post
  match 'app/login_social',     to: 'iphone#login_social',     via: :post
  match 'app/update',           to: 'app#relays',              via: :post
  match 'app/update_user',      to: 'app#update_user',         via: :post
  match 'app/gifts_array',      to: 'app#gifts',               via: :post
  match 'app/archive',          to: 'iphone#archive',          via: :post
  match 'app/brands',           to: 'app#brands',              via: :post
  match 'app/brand_merchants',  to: 'app#brand_merchants',     via: :post
  match 'app/providers',        to: 'app#providers',           via: :post
  match 'app/get_providers',    to: 'app#providers',           via: :get
  match 'app/redeem',           to: 'app#create_redeem',       via: :post
  match 'app/order_confirm',    to: 'app#create_order',        via: :post
  match 'app/menu_v2',          to: 'app#menu_v2',             via: :post
  match 'app/questions',        to: 'app#questions',           via: :post
  match 'app/others_questions', to: 'app#others_questions',    via: :post
  match 'app/transactions',     to: 'app#transactions',        via: :post
  match 'app/users_array',      to: 'app#drinkboard_users',    via: :post
  match 'app/create_gift',      to: 'app#create_gift',         via: :post
  match 'app/buy_gift',         to: 'app#create_gift',         via: :post
  match 'app/photo',            to: 'iphone#update_photo',     via: :post
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
  match 'app/locations',        to: 'iphone#locations',        via: :post
  match 'app/out',              to: 'iphone#going_out',        via: :post
  match 'app/buys',             to: 'iphone#buys',             via: :post
  match 'app/past_gifts',       to: 'app#past_gifts',          via: :post
  match 'app/orders',           to: 'app#orders',              via: :post
  match 'app/merchant_redeem',  to: 'app#merchant_redeem',     via: :post
  match 'app/user_activity',    to: 'app#user_activity',       via: :post
  match 'app/employees',        to: 'app#create_redeem_emps',  via: :post
  match 'app/complete_order',   to: 'app#create_order_emp',    via: :post

#################        Mdot V2 API                              /////////////////////////////

  namespace :mdot, defaults: { format: 'json' } do
    namespace :v2 do

      resources :sessions,    only: [:create] do
        post :login_social
      end
      resources :users,       only: [:index, :create, :update] do
        member do
          post :reset_password
        end
        resources :cards,     only: [:index, :create, :delete]
        resources :settings,  only: [:show, :update]
        resources :gifts,     only: [:index, :create] do
          resources :redeems, only: [:create]
          resources :orders,  only: [:create]
          member do
            post :regift
            get  :archive
          end
          collection do
            get :badge  #update or relay
            get :transactions
          end
        end
        resources :photos,     only: [:update] do
          member do
            get  :short_url
          end
        end
        resources :questions, only: [:index, :update]
      end

      resources :providers,   only: [:show] do
        resources :menus,     only: [:show]
      end
      resources :brands,      only: [:index] do
        resources :providers, only: [:index]
      end
      resources :cities,      only: [:index] do
        resources :providers, only: [:index]
      end

    end
  end


#################          PUBLIC website routes                  /////////////////////////////

  namespace :web, defaults: { format: 'json' } do
    namespace :v1 do
      post 'confirm_email',      to: 'websites#confirm_email'
      post 'redo_confirm_email', to: 'websites#redo_confirm_email'
      resources :providers, only: [:show]
    end
  end

  namespace :web, defaults: { format: 'json' } do
    namespace :v2 do
      resources :merchants, only: [:show]
    end
  end

#################          ADMIN TOOLS routes for API              /////////////////////////////

  namespace :admt, defaults: { format: 'json' } do
    namespace :v1 do
      post 'de_activate_user',  to: 'admin_tools#deactivate_user'
      post 'destroy_all_gifts', to: 'admin_tools#destroy_all_gifts'
      post 'destroy_user',      to: 'admin_tools#destroy_user'
      post 'update_user',       to: 'admin_tools#update_user'
      post 'create_brand',      to: 'admin_tools#create_brand'
      post 'update_brand',      to: 'admin_tools#update_brand'
      post 'de_activate_brand', to: 'admin_tools#deactivate_brand'
      post 'go_live',           to: 'admin_tools#go_live'
      post 'deactivate_merchant', to: 'admin_tools#deactivate_merchant'
      post 'update_mode',       to: 'admin_tools#update_mode'
      post 'cancel',            to: 'admin_tools#cancel'
      post 'settled',           to: 'admin_tools#settled'
    end
  end

  namespace :admt, defaults: { format: 'json' } do
      namespace :v2 do

          resources :gifts,     only: [:update] do         # biz logic
            member do
              post :refund                  # biz logic
              post :refund_cancel           # biz logic
            end
            collection do
              post :destroy_all             # biz logic
            end
          end

          resources :users,     only: [:update, :destroy]  # biz logic

          resources :brands,    only: [:create, :update]   # biz logic

          resources :providers, only: [] do
            member do
              post :update_mode             # biz logic
              post :deactivate              # biz logic
            end
          end
      end
  end

#################          MERCHANT TOOLS routes for API          /////////////////////////////

  namespace :mt, defaults: { format: 'json' } do
    namespace :v2 do

      resources :merchants, only: [:create, :update] do
        resources :orders,  only: [:show, :index]
        resources :menus,   only: [:update]
        resources :photos,  only: [:update]
        member do
          post :reconcile
        end
      end

    end
  end

  namespace :mt, defaults: { format: 'json' } do
    namespace :v1 do
      post 'create_merchant', to: 'merchant_tools#create'
      post 'update_merchant', to: 'merchant_tools#update'
      post 'compile_menu',    to: 'merchant_tools#compile_menu'
      post 'update_photo',    to: 'merchant_tools#update_photo'
      post 'reconcile_merchants', to: 'merchant_tools#reconcile_merchants'
    end
  end

#################          HTML routes good                       /////////////////////////////

  mount Resque::Server, :at => "/resque"

#################          HTML routes to deprecate               /////////////////////////////

end
