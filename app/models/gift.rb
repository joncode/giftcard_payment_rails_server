class Gift < ActiveRecord::Base
	extend  GiftScopes
	include Formatter

	attr_accessible   	  :giver_id, 	  :giver_name,
			:receiver_id, :receiver_name, :receiver_phone,
			:provider_id, :provider_name, :receiver_email,
			:message,     :shoppingCart,
			:tip, :tax,   :total, :service,
			:facebook_id, :foursquare_id, :twitter,
			:status, :credit_card
			# should be removed from accessible = giver_id, giver_name, shoppingCart, status

			# from the app on create gift
# \"receiver_email\" \"facebook_id\"\"tax\"  \"receiver_phone\"  \"giver_name\"
# \"receiver_id\"  \"total\"  \"provider_id\"  \"tip\"  \"service\"  \"message\"
# \"credit_card\"  \"provider_name\"  \"receiver_name\"  \"giver_id\"  "origin"=>"d"
# "shoppingCart"=>"[{\"price\":\"10\",\"quantity\":1,\"item_id\":920,\"item_name\":\"Fireman's Special\"},{\"price\":\"10\",\"quantity\":1,\"item_id\":901,\"item_name\":\"Corona\"},{\"price\":\"10\",\"quantity\":1,\"item_id\":902,\"item_name\":\"Budwesier\"}]",
# "token"=>"LlWODlRC9M3VDbzPHuWMdA"}

	has_one     :redeem, 		dependent: :destroy
	has_one     :relay,  		dependent: :destroy
	belongs_to  :provider
	has_many    :sales
	has_one     :order, 		dependent: :destroy
	has_many    :gift_items, 	dependent: :destroy
	belongs_to  :giver,    		class_name: "User"
	belongs_to  :receiver, 		class_name: "User"

	validates_presence_of :giver_id, :receiver_name, :provider_id, :total, :credit_card

	before_create :extract_phone_digits
	before_create :add_giver_name,  :if => :no_giver_name
	before_create :regifted,        :if => :regift?
	before_create :set_status

	after_create  :update_shoppingCart

	default_scope where(active: true)

#/---------------------------------------------------------------------------------------------/

	def serialize
		sender      = giver
		merchant    = provider
		gift_hsh                       = {}
		gift_hsh["gift_id"]			   = self.id
		gift_hsh["giver"]              = sender.name
		gift_hsh["giver_photo"]        = sender.get_photo
		if receipient = receiver
			gift_hsh["receiver"]           = receiver.name
			gift_hsh["receiver_photo"]	   = receiver.get_photo
		else
			gift_hsh["receiver"]           = receiver_name
		end
		gift_hsh["message"]            = message
		gift_hsh["shoppingCart"]       = ary_of_shopping_cart_as_hash
		gift_hsh["merchant_name"]      = merchant.name
		gift_hsh["merchant_address"]   = merchant.full_address
		gift_hsh["merchant_phone"]     = merchant.phone
		gift_hsh
	end

	def admt_serialize
		provider = self.provider
		gift_hsh                       = {}
		gift_hsh["gift_id"]			   = self.id
		gift_hsh["provider_id"]        = provider.id
		#gift_hsh["merchant_id"]        = provider.merchant_id if provider.merchant_id
		gift_hsh["name"]      		   = provider.name
		gift_hsh["merchant_address"]   = provider.full_address
		gift_hsh["total"]   		   = self.total
		gift_hsh["updated_at"]   	   = self.updated_at
		gift_hsh
	end

	def report_serialize
		gift_hsh                    = {}
		gift_hsh["order_num"]		= self.order_num
		gift_hsh["updated_at"]		= self.updated_at
		gift_hsh["created_at"]		= self.created_at
			# current summary and payment reports use item coun NOT shopping cart ... delete when in sync
		gift_hsh["shoppingCart"]  	= self.shoppingCart
		if order = self.order
			server = self.order.server_code
		else
			server = nil
		end
		gift_hsh["server"]			= server
		gift_hsh["total"]			= self.total
		gift_hsh
	end

	def self.init(params)
		gift = Gift.new(params[:gift])
				# add anonymous giver feature
		if params[:gift][:anon_id]
			gift.add_anonymous_giver(params[:gift][:giver_id])
		end
		return gift
	end

	def phone
		self.receiver_phone
	end

	def phone= phone_number
		self.receiver_phone = phone_number
	end

	def grand_total
		pre_round = self.total.to_f + self.service.to_f
		pre_round.round(2).to_s
	end

	def total
		string_to_cents super
	end

	def service
		string_to_cents super
	end

##########  gift credit card methods

	def set_status
		if card_enabled?
			if Rails.env.production? || Rails.env.staging?
				self.status = "unpaid"
			else
				set_status_post_payment
			end
		else
			set_status_post_payment
		end
		puts "gift SET STATUS #{self.status}"
	end

	def set_status_post_payment
		if self.receiver_id.nil?
			self.status = "incomplete"
		else
			self.status = 'open'
		end
	end

	def card_enabled?
		# whitelist = ["test@test.com", "deb@knead4health.com", "dfennell@graywolves.com", "dfennell@webteampros.com"]
		# blacklist = ["addis006@gmail.com"]
		# if blacklist.include?(self.giver.email)
		# 	return false
		# else
		# return true
		# end
		return true
	end

	def charge_card
				# if giver is one jb@jb.com
				# call authorize capture on the gift and create the sale object
		if Rails.env.production? || Rails.env.staging?
			if true # self.card_enabled?
				sale = self.authorize_capture
				puts "SALE ! #{sale.req_json} #{sale.transaction_id} #{sale.revenue.to_f} == #{self.total}"
			else
				sale = Sale.new
				sale.resp_code = 1
			end
		else
			sale     = Sale.init self
			sale.resp_code = 1
		end
		if sale.resp_code == 1 && self.status == 'open'
			if Rails.env.production? || Rails.env.staging?
				# not in production for APNS YET
				begin
					Relay.send_push_notification self
				rescue
					puts "PUSH NOTIFICATION FAIL"
				end
			elsif Rails.env.development?
				Relay.send_push_notification self
				sale.invoice_giver
				sale.notify_receiver
			end
		end
				# otherwise return a sale object with resp_code == 1
		return sale
	end

	def authorize_capture
		puts "BEGIN AUTH CAPTURE for GIFT ID #{self.id}"
			# Authorize Transaction Method
		# A - create a sale object that stores the record of the auth.net transaction
		sale     = Sale.init self
		response = sale.auth_capture

		# B - authorize transaction via auth.net
			# -- returns data --
				# 1 success
					# go ahead and save the gift - process complete
				# failure
					# credit card issues
						# card expired
						# insufficient funds
						# card is blocked
					# auth.net issues
						# cannot connect to server
						# no response from server
						# transaction key is no longer good
					# sale db issues
						# could not save item
		case response.response_code.to_i
		when 1
			# Approved
			puts "setting the gift status off unpaid"
			set_status_post_payment
			self.save
		when 2
			# Declined
		when 3
			# Error
			# duplicate transaction response subcode = 1
		when 4
			# Held for Review
		else
			# not a listed error code
			puts "UNKNOWN ERROR CODE RECEIVED FOR AUTH.NET - CODE = #{response.response_code}"
			puts "TEXT IS #{response.response_reason_text} for GIFT ID = #{self.id}"
		end
		reply = response.response_reason_text
		puts "HERE IS THE REPLY #{reply}"
		# C - saves the sale object into the sale db
		if sale.save
			puts "save of sale successful"
		else
			puts "save of sale ERROR gift ID = #{self.id}"
		end
		return sale
	end

###############

##########  data population methods

	def regift(recipient=nil, message=nil)
		new_gift              = self.dup
		new_gift.regift_id    = self.id
		new_gift.message      = message ? message : nil
		new_gift.add_giver(self.receiver)
		if recipient
			new_gift.add_receiver recipient
		else
			new_gift.remove_receiver
		end
		new_gift.order_num  = nil
		return new_gift
	end

	def parent
		if self.regift_id
			Gift.find(self.regift_id)
		else
			nil
		end
	end

	def child
		Gift.find_by_regift_id(self.id)
	end

	def remove_receiver
		self.receiver_id    = nil
		self.receiver_name  = nil
		self.facebook_id    = nil
		self.receiver_phone = nil
		self.receiver_email = nil
		self.status 		= "unpaid"
	end

	def add_receiver receiver
		self.receiver_id    = receiver.id
		self.receiver_name  = receiver.name
		self.facebook_id    = receiver.facebook_id ? receiver.facebook_id : nil
		self.receiver_phone = receiver.phone ? receiver.phone : nil
		self.receiver_email = receiver.email ? receiver.email : nil
		self.status 		= 'open' if receiver.id
	end

	def add_giver sender
		self.giver_id   = sender.id
		self.giver_name = sender.name
	end

	def add_provider provider
		self.provider_id   = provider.id
		self.provider_name = provider.name
	end

	def add_anonymous_giver giver_id
		anon_user       = User.find_by_phone('5555555555')
		self.add_giver anon_user
		self.anon_id    = giver_id
	end

###############

##########  shopping cart methods

	def ary_of_shopping_cart_as_hash
		JSON.parse self.shoppingCart
	end

	def make_gift_items shoppingCart_array
		puts "In make gift items #{shoppingCart_array}"
		self.gift_items = shoppingCart_array.map do |item|
			GiftItem.initFromDictionary(item)
		end
		puts "made it thru gift items #{self.gift_items}"
	end

private

	def update_shoppingCart
		if self.regift_id.nil?
			updated_shoppingCart_array = self.gift_items.map { |item| item.prepare_for_shoppingCart }
			puts "GIFT AFTER SAVE UPDATING SHOPPNG CART = #{updated_shoppingCart_array}"
			self.update_attribute(:shoppingCart, updated_shoppingCart_array.to_json)
		end
	end

	def add_giver_name
		self.giver_name = User.find(self.giver_id).username
	end

	def no_giver_name
		self.giver_name.nil?
	end

	def regifted
		old_gift = Gift.find(self.regift_id)
		old_gift.update_attributes(status: 'regifted')
	end

	def regift?
		self.regift_id
	end
end
# == Schema Information
#
# Table name: gifts
#
#  id             :integer         not null, primary key
#  giver_name     :string(255)
#  receiver_name  :string(255)
#  provider_name  :string(255)
#  giver_id       :integer
#  receiver_id    :integer
#  total          :string(20)
#  credit_card    :string(100)
#  provider_id    :integer
#  message        :text
#  status         :string(255)     default("unpaid")
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#  receiver_phone :string(255)
#  tax            :string(255)
#  tip            :string(255)
#  regift_id      :integer
#  foursquare_id  :string(255)
#  facebook_id    :string(255)
#  anon_id        :integer
#  sale_id        :integer
#  receiver_email :string(255)
#  shoppingCart   :text
#  twitter        :string(255)
#  service        :string(255)
#  order_num      :string(255)
#  cat            :integer         default(0)
#  active         :boolean         default(TRUE)
#

