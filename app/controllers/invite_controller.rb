class InviteController < ApplicationController
	layout 'user_mailer' , except: [:show, :invite, :invite_friend]
	layout 'html_good', only: [ :facebook_checkin]

# ------------------------

	def facebook_checkin
		puts " *************    FACEBOOK CHECKIN   ********"
		puts params.inspect
		if request.headers['Authorization']
			puts "HERE IS the Authorization #{request.headers['Authorization']}"
		end
	end

# ------------------------

	def show

				# remove the permalink add-number from the id
		id = params[:id].to_i - NUMBER_ID

		if gift = Gift.find(id)
			response_hash = gift.serialize
		else
			response_hash = { "error" => "Incorrect Data Received"}
		end

		respond_to do |format|
			format.json { render json: response_hash }
		end
	end

	def invite
						# remove the permalink add-number from the id
		id = params[:id].to_i - NUMBER_ID
		if id < 0
				id = params[:id].to_i
		end
		@user = User.find(id)
		if @user.nil?
				@user = User.find_by(phone: "5555555555")
		end
		if request.format == :json
				response_hash                       = {}
				response_hash["user"]               = @user.name
				response_hash["user_photo"]         = @user.get_photo
		end
		respond_to do |format|
				format.json { render json: response_hash }
		end
	end

	def error
		@email_title   = "#{SERVICE_NAME} Email Messenger"
		@header_text   = "We're Sorry but there was an Error"
		@social = 1
		@web_view_route = "#{TEST_URL}/invite/error"

		respond_to do |format|
			format.html
		end
	end

	def email_confirmed
		@email_title   = "#{SERVICE_NAME} Email Messenger"

		@header_text   = "Thank You, Your Email is Confirmed"
		@social = 1
		@web_view_route = "#{TEST_URL}/invite/email_confirmed"

		respond_to do |format|
			format.html
		end
	end

	def display_email
		@email_title   = "#{SERVICE_NAME} Email Messenger"
		@header_text   = "#MobileGifting"
		@social = 1
		@web_view_route = create_webview_link

		case params[:template]
		when 'confirm_email'
				#  you've just joined the app , confirm your email
			email_view    = "confirm_email"
			user_id       = params[:var1].to_i - NUMBER_ID
			@user         = User.find(user_id)
			@user_id      = @user.id + NUMBER_ID
			@header_text  = "Confirm Your Email Address"
			@social       = 0
		when 'reset_password'
				#  you have forgotten your password and would like to reset it
			email_view    = "reset_password"
			@user         = User.find(params[:var1])
			@header_text  = ""
			@social       = 0
		# when 'invite_employee'
		#     #  you have forgotten your password and would like to reset it
		#   email_view    = "invite_employee"
		#   @user         = User.first
		#   @email        = params[:var1]
		#   @header_text  = "#{SERVICE_NAME} Merchant Employee Request "
		#   @social       = 0
		when 'invoice_giver'
				#  giver gets invoice email when gift is purchased - incomplete or open
			email_view    = "invoice_giver"
			@header_text  = "Purchase Complete , Thank You"
			@gift         = Gift.find(params[:var1])
			@cart         = @gift.ary_of_shopping_cart_as_hash
			@merchant     = @gift.provider
		when 'notify_receiver'
				#  receiver gets email when gift is purchased for them - open
			email_view    = "notify_receiver"
			@header_text  = "You have Received a Gift"
			@gift         = Gift.find(params[:var1])
			@cart         = @gift.ary_of_shopping_cart_as_hash
			@merchant     = @gift.provider
		when 'notify_giver_order_complete'
				#  giver gets email when order is created (completed gift)
			email_view    = "notify_giver_order_complete"
			@header_text  = "Your Gift Has Been Redeemed"
			@gift         = Gift.find(params[:var1])
			@cart         = @gift.ary_of_shopping_cart_as_hash
			@merchant     = @gift.provider
		when 'notify_giver_created_user'
				#  giver gets email when receiver has received email - incomplete => open
			email_view    = "notify_giver_created_user"
			@header_text  = "Your Gift has been Received"
			@gift         = Gift.find(params[:var1])
			@cart         = @gift.ary_of_shopping_cart_as_hash
			@merchant     = @gift.provider
		else
				#  join its on me email
			email_view    = "display_email"
			@web_view_route = "#{TEST_URL}/webview/display_email"
		end

		respond_to do |format|
			format.html { render  email_view }
		end

	end

private

	def create_webview_link
		"#{TEST_URL}/webview/#{params[:template]}/#{params[:var1]}"
	end

end


# INVITE W/O GIFT
# sender info :
		# sender name
		# sender photo_url

# request with
		# invite/person/782934
		# 782934 = <user_id + stub value>
# respond with
		# { "user" : <fullname>, "photo" : <user.get_photo> }

# INVITE W GIFT
		# sender info (see above)
# gift info :
		# gift items - shopping cart
		# merchant name
		# merchant photo_url
		# merchant address
		# merchant phone

# request with
		# invite/gift/782934
		# 782934 = <gift_id + stub value>
# respond with
		# { "user" : <fullname>,
		#  "photo" : <user.get_photo>,
		#  "shoppingCart" : <shopping cart as json hash> ,
		#  "merchant_name" : <provider_name>,
		#  "merchant_address" : <provider_full_address>,
		#  "merchant_phone" : <provider_phone> }
