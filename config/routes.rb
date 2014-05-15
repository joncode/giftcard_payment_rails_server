Drinkboard::Application.routes.draw do

  match '/facebook/checkin', to: "invite#facebook_checkin", via: :post

#################         iOS app & Mdot V1 API                   /////////////////////////////


    ###  mobile app routes
  post 'app/create_account',   to: 'iphone#create_account'
  post 'app/login',            to: 'iphone#login'
  post 'app/login_social',     to: 'iphone#login_social'
  post 'app/update',           to: 'app#relays'
  post 'app/update_user',      to: 'app#update_user'
  post 'app/archive',          to: 'app#archive'
  post 'app/brands',           to: 'app#brands'
  post 'app/brand_merchants',  to: 'app#brand_merchants'
  post 'app/providers',        to: 'app#providers'
  get  'app/get_providers',    to: 'app#providers'
  post 'app/redeem',           to: 'app#create_redeem'
  post 'app/order_confirm',    to: 'app#create_order'
  post 'app/menu_v2',          to: 'app#menu_v2'
  post 'app/questions',        to: 'app#questions'
  post 'app/others_questions', to: 'app#others_questions'
  post 'app/users_array',      to: 'app#drinkboard_users'
  post 'app/create_gift',      to: 'app#create_gift'
  post 'app/buy_gift',         to: 'app#create_gift'
  post 'app/photo',            to: 'iphone#update_photo'
  post 'app/reset_password',   to: 'app#reset_password'
  post 'app/get_settings',     to: 'app#get_settings'
  post 'app/save_settings',    to: 'app#save_settings'
  post 'app/m_save_settings',  to: 'app#save_settings_m'
  post 'app/regift',           to: 'iphone#regift'

    ## credit card routes
  post 'app/cards',            to: 'app#get_cards'
  post 'app/add_card',         to: 'app#add_card'
  post 'app/delete_card',      to: 'app#delete_card'

    ## test new data methods routes
  post 'app/new_pic',          to: 'app#providers_short_ph_url'
  post 'app/cities_app',       to: 'iphone#cities'

    ### deprecated app routes
  post 'app/menu',             to: 'app#menu'
  post 'app/locations',        to: 'iphone#locations'
  post 'app/buys',             to: 'iphone#buys'
  post 'app/past_gifts',       to: 'app#past_gifts'
  post 'app/orders',           to: 'app#orders'
  post 'app/user_activity',    to: 'app#user_activity'
  post 'app/complete_order',   to: 'app#create_order_emp'
  post 'app/gifts_array',      to: 'app#gifts'
  post 'app/transactions',     to: 'app#transactions'

#################          Client V3 routes for API                  /////////////////////////////

  namespace :client, defaults: { format: 'json' } do
    namespace :v3 do

      resources :cities,     only: [:index] do
        member do
          get :merchants
        end
      end

      resources :merchants

    end
  end

#################          POS V1 routes for API                  /////////////////////////////

  namespace :pos, defaults: { format: 'json' } do
    namespace :v1 do

      resources :orders, only: [:create]

    end
  end

#################        Mdot V2 API                              /////////////////////////////

  namespace :mdot, defaults: { format: 'json' } do
    namespace :v2 do

      resources :sessions,  only: [:create] do
        collection do
          post :login_social
        end
      end
      resources :users,     only: [:index, :create, :show] do
        collection do
          put :update
          put :reset_password
          put :deactivate_user_social
          get :profile
          put :socials
        end
      end
      resources :facebook,     only: [:create] do
        collection do
          get   :friends
          get   :profile
          post  :oauth
        end
      end
      resources :twitter,     only: [:create] do
        collection do
          get   :friends
          get   :profile
          post  :oauth
        end
      end
      resources :user_socials, only: [] do
        collection do
          delete :destroy
        end
      end
      resources :contacts, only: [] do
        collection do
          post :upload
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
          get :badge         # old method names -> update or relay
        end
      end
      resources :photos,     only: [:create]
      resources :questions,  only: [:index] do
        collection do
          put :update
        end
      end

      resources :providers,  only: [] do
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

    namespace :v2 do
      resources :merchants, only: [:show]
    end
  end

#################          ADMIN TOOLS routes for API              /////////////////////////////

  namespace :admt, defaults: { format: 'json' } do
      namespace :v2 do

          resources :gifts,     only: [:update, :create] do         # biz logic
            member do
              post :refund                  # biz logic
              post :refund_cancel           # biz logic
              put  :add_receiver
            end
          end

          resources :gift_campaigns, only: [:create]

          resources :users,     only: [:update] do         # biz logic
            member do
              post :deactivate
              post :suspend
              put :deactivate_social
              post :deactivate_gifts
            end
          end

          # resources :user_socials, only: [:create, :update]

          resources :brands,    only: [:create, :update]   # biz logic

          resources :providers, only: [:create, :update] do
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

      resources :gifts, only: [] do
        collection do
          post :bulk_create
        end
      end

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
  get '/signin',             to: 'sessions#new'
  get '/signout',            to: 'sessions#destroy'
  get '/forgot_password',    to: 'sessions#forgot_password'
  post '/forgot_password',    to: 'sessions#forgot_password'
  get '/reset_password',     to: 'sessions#forgot_password'
  get '/enter_new_password', to: 'sessions#enter_new_password'
  put '/enter_new_password', to: 'sessions#enter_new_password'
  get '/valid_token',        to: 'sessions#validate_token'
  post '/change_password/:id', to: 'sessions#change_password'

  get "/invite/email_confirmed"     , to: "invite#email_confirmed"
  get "/invite/error"               , to: "invite#error"
  get "/invite/gift/:id"            , to: "invite#show"
  get "/invite/person/:id"          , to: "invite#invite"
  get "/webview(/:template(/:var1))", to: "invite#display_email"

  get "/confirm_email(/:email(/:user))", to: "users#confirm_email"
  mount Resque::Server, :at => "/resque"

#################          HTML routes to deprecate               /////////////////////////////

end
