Drinkboard::Application.routes.draw do


#################         iOS app & Mdot V1 API                   /////////////////////////////

    ###  mobile app routes
  match 'app/create_account',   to: 'iphone#create_account',   via: :post
  match 'app/login',            to: 'iphone#login',            via: :post
  match 'app/login_social',     to: 'iphone#login_social',     via: :post
  match 'app/update',           to: 'app#relays',              via: :post
  match 'app/update_user',      to: 'app#update_user',         via: :post
  match 'app/archive',          to: 'app#archive',             via: :post
  match 'app/brands',           to: 'app#brands',              via: :post
  match 'app/brand_merchants',  to: 'app#brand_merchants',     via: :post
  match 'app/providers',        to: 'app#providers',           via: :post
  match 'app/get_providers',    to: 'app#providers',           via: :get
  match 'app/redeem',           to: 'app#create_redeem',       via: :post
  match 'app/order_confirm',    to: 'app#create_order',        via: :post
  match 'app/menu_v2',          to: 'app#menu_v2',             via: :post
  match 'app/questions',        to: 'app#questions',           via: :post
  match 'app/others_questions', to: 'app#others_questions',    via: :post
  match 'app/users_array',      to: 'app#drinkboard_users',    via: :post
  match 'app/create_gift',      to: 'app#create_gift',         via: :post
  match 'app/buy_gift',         to: 'app#create_gift',         via: :post
  match 'app/photo',            to: 'iphone#update_photo',     via: :post
  match 'app/reset_password',   to: 'app#reset_password',      via: :post
  match 'app/get_settings',     to: 'app#get_settings',        via: :post
  match 'app/save_settings',    to: 'app#save_settings',       via: :post
  match 'app/m_save_settings',  to: 'app#save_settings_m',     via: :post
  match 'app/regift',           to: 'iphone#regift',           via: :post

    ## credit card routes
  match 'app/cards',            to: 'app#get_cards',           via: :post
  match 'app/add_card',         to: 'app#add_card',            via: :post
  match 'app/delete_card',      to: 'app#delete_card',         via: :post

    ## test new data methods routes
  match 'app/new_pic',          to: 'app#providers_short_ph_url', via: :post
  match 'app/cities_app',       to: 'iphone#cities'

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
  match 'app/gifts_array',      to: 'app#gifts',               via: :post
  match 'app/transactions',     to: 'app#transactions',        via: :post

#################        Mdot V2 API                              /////////////////////////////

  namespace :mdot, defaults: { format: 'json' } do
    namespace :v2 do

      resources :sessions,  only: [:create] do
        collection do
          post :login_social
        end
      end
      resources :users,     only: [:index, :create] do
        collection do
          put :update
          put :reset_password
        end
      end
      resources :brands,     only: [:index] do
        member do
          get :merchants
        end
      end
      resources :cities,     only: [:index] do
        member do
          get :merchants
        end
      end

      resources :cards,     only: [:index, :create, :destroy]

      resources :settings,  only: [:index] do
        collection do
          put :update
        end
      end
      resources :gifts,     only: [:create] do
        member do
          post :regift
          post :open
          post :redeem
        end
        collection do
          get :archive
          get :badge  #update or relay
        end
      end
      resources :photos,     only: [:create]
      resources :questions,  only: [:index] do
        collection do
          put :update
        end
      end

      resources :providers,  only: [:show] do
        member do
          get :menu
        end
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
      namespace :v2 do

          resources :gifts,     only: [:update] do         # biz logic
            member do
              post :refund                  # biz logic
              post :refund_cancel           # biz logic
            end
          end

          resources :users,     only: [:update] do         # biz logic
            member do
              post :deactivate
              post :deactivate_gifts
            end
          end

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

        member do
          post :reconcile
          put  :menu
        end
      end
    end
  end

#################          HTML routes good                       /////////////////////////////
  root                         to: 'sessions#new'
  resources :sessions,       only: [:new, :create, :destroy]
  match '/signin',             to: 'sessions#new',                via: :get
  match '/signout',            to: 'sessions#destroy'
  match '/forgot_password',    to: 'sessions#forgot_password',    via: [:get, :post]
  match '/reset_password',     to: 'sessions#forgot_password',    via:  :get
  match '/enter_new_password', to: 'sessions#enter_new_password', via: [:get, :put]
  match '/valid_token',        to: 'sessions#validate_token',     via: :get
  match '/change_password/:id', to: 'sessions#change_password',    via: :post

  match "/invite/email_confirmed"     , to: "invite#email_confirmed", via: :get
  match "/invite/error"               , to: "invite#error",           via: :get
  match "/invite/gift/:id"            , to: "invite#show",            via: :get
  match "/invite/person/:id"          , to: "invite#invite",          via: :get
  match "/webview(/:template(/:var1))", to: "invite#display_email",   via: :get

  match "/confirm_email(/:email(/:user))", to: "users#confirm_email", via: :get
  mount Resque::Server, :at => "/resque"

#################          HTML routes to deprecate               /////////////////////////////

end
