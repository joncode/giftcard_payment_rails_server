class AdminController < ApplicationController
  	before_filter :signed_in_user
  	before_filter :admin_user?
  	DEVICE_TOKEN = '8ac249f29b7d8a5ad9c334d3a915a02c9cc177322436ba7c7e854bc54e2a23b1'

  	def push_register
  		flash[:notice] 	= "register"
  		pntoken = PnToken.find_by_pn_token(DEVICE_TOKEN)
  		user 			= pntoken.user if pntoken
  		ua_alias 		= user ? user.ua_alias : "test"
  		Urbanairship.register_device(DEVICE_TOKEN, :alias => "#{ua_alias}", :tag => ["tester"] )
  		render 'show'
  	end

  	def push_notify
  		msg = 'Hello from AdminController! via alias'
  		pntoken = PnToken.find_by_pn_token(DEVICE_TOKEN)
  		user 			= pntoken.user if pntoken
  		ua_alias 		= user ? user.ua_alias : "test"
		notification = {
		  :aliases => [ua_alias],
		  :aps => {:alert => msg, :badge => 5}
		}
		resp = Urbanairship.push(notification)
		flash[:notice] = msg + resp.inspect
  		render 'show'
  	end

	def show

	end

	def test_emails

	end

	def run_tests
		# how to make these all
			# 1. email to "noreplydrinkboard@gmail.com"
			# 2. have gift data
			# 3. have provider data
		email = "test@test.com"
		user  = User.find_by_email "test@test.com"
		gifts = Gift.where(giver_id: user.id, receiver_id: user.id)
		# needs to check that there is a shoppingCart
		gift, flag = find_gift_with_order_and_shoppingCart(gifts)
		puts "TEST ALL GIFTS WITH #{gift.inspect}"

		if flag
			Resque.enqueue(EmailJob, 'notify_giver_order_complete', user.id , {:gift_id => gift.id})
 			@message = "8 email tests sent to #{email}"
 		else
 			@message = "7 email tests sent to #{email}, 1 not sent 'noitfy_giver_order_complete'"
 		end
		provider = gift.provider
		Resque.enqueue(EmailJob, 'confirm_email', 	user.id , 	{})
		Resque.enqueue(EmailJob, 'reset_password', 	user.id, 	{})
		Resque.enqueue(EmailJob, 'invite_friend', 	user.id , 	{:email => email, :gift_id => gift.id})
		Resque.enqueue(EmailJob, 'invite_employee', user.id , 	{:provider_id => provider.id,:email => email, :gift_id => gift.id})
		Resque.enqueue(EmailJob, 'notify_giver_created_user', 	user.id  , 	{:gift_id => gift.id})
		Resque.enqueue(EmailJob, 'notify_receiver', user.id , 	{:gift_id => gift.id, :email => email})
		Resque.enqueue(EmailJob, 'invoice_giver', 	user.id  , 	{:gift_id => gift.id})
	end

	private

	def find_gift_with_order_and_shoppingCart(gifts)
		# criteria for a proper gift
		# - has a shopping cart
		# - has an order
		# - has a receiver with image

		flag = false
		gift = gifts[0]
		gifts.each do |g|
			if g.order
				flag = true
				gift = g
			end
		end

		cart = JSON.parse gift.shoppingCart
		items = cart.count
		index = 1
		while items == 0
			cart = JSON.parse gifts[index].shoppingCart
			items = cart.count
			gift = gifts[index]
			index += 1
			if index == gifts.count
				if gift.receiver_id
					items = 3
				end
			end
		end
		return gift, flag
	end

end
