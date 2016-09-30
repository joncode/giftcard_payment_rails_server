Drinkboard::Application.routes.draw do

	root  to: 'react#index'
	match '/facebook/checkin', to: "invite#facebook_checkin", via: :post

    # if !Rails.env.production?
    get '/papergifts/:id',  to: 'invite#paper_gifts'
    # end

#################        Mdot V2 API                              /////////////////////////////


	namespace :events, defaults: { format: 'json' } do
		resources :callbacks,  only: [] do
			collection do
				post :receive_sms
				post :zappernotify
			end
		end
	end

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
					get :refresh
					put :socials
					post :authorize
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

			resources :cards,     only: [:index, :create, :destroy] do
				collection do
					#get :tokenize
					#post :create_token
				end
			end

			resources :settings,  only: [:index] do
				collection do
					put :update
				end
			end
			resources :gifts,     only: [:index, :create] do
				member do
					post :regift
					post :open
					post :notify
					post :redeem
					post :pos_redeem
				end
				collection do
					get :archive
					get :badge         # old method names -> update or relay
					post :promo
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
					get :receipt_photo_url
					get :redeem_locations
				end
			end

		end
	end


#################          website routes                  /////////////////////////////

	namespace :web, defaults: { format: 'json' } do

		namespace :v1 do
			post 'confirm_email',      to: 'websites#confirm_email'
			post 'redo_confirm_email', to: 'websites#redo_confirm_email'
			resources :providers, only: [:show]
		end

		namespace :v2 do
			resources :merchants, only: [:show]
		end

		namespace :v3 do
			resources :cards, only: [:create, :index, :destroy]
			resources :clients, only: [:index, :create]
			resources :courses, only: [:index] do
				collection { get :revenue }
			end

			resources :devices, only: [ :create ] do
				collection { get :config }
			end

			resources :facebook,     only: [:create] do
				collection do
					get   :friends
					get   :app_friends
					get   :taggable_friends
					get   :profile
					post  :oauth
					get   :oauth_init
					get   :callback_url
					post  :share
				end
			end

			resources :gifts, only: [:index, :create, :show] do
				member do
					patch :read
					patch :notify
					patch :redeem
					get :current_redemption
					post :regift
					get :hex
				end
				collection do
					post :promo
				end
			end

			resources :lists, only: [ :index, :show ]
			resources :menu_items, only: [ :show ]

			resources :merchants, only: [:index, :show] do
				member do
					get :menu
					get :receipt_photo_url
					get :redeem_locations
				end
				collection do
					post :signup
				end
			end

			resources :promos, only: [:create, :show] do
				collection do
					patch :click
					post :redbull
				end
			end

			resources :regions,   only: [:index] do
				member { get :merchants }
			end

			resources :sessions,  only: [:create] do
				collection do
					post :logout
				end
			end

			resources :twitter,     only: [:create] do
				collection do
					# get   :friends
					# get   :profile
					post  :oauth
				end
			end

			resources :users, only: [ :create, :index ] do
				collection do
					get   :refresh
					patch :update
					patch :reset_password
					post :facebook
					patch :attach_facebook
				end
				member do
					delete :socials
					get :activate
					post :authorize
				end
			end
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

			resources :gift_campaigns, only: [:create] do
				collection { post :bulk_create }
			end

			resources :protos,  only: [] do
				member  do
					post :gifts
				end
			end

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

			resources :emailers, only: [] do
				collection do
					post :call_emailer
				end
			end

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
					post :redeem
				end
				member do
					post :proto_join
				end
			end
			resources :protos,  only: [] do
				member  do
					post :gifts
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


#################          POS V1 routes for API                  /////////////////////////////

	namespace :pos, defaults: { format: 'json' } do
		namespace :v1 do

			resources :orders, only: [:create]

		end
	end

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

	get 'emails/template', to: 'emails#template'

end
