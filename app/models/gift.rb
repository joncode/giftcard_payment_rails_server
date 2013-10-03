class Gift < ActiveRecord::Base
	extend  GiftScopes
	include Formatter
	include Email
	include GiftSerializers

	attr_accessible   	  :giver_id, 	  :giver_name,
			:receiver_id, :receiver_name, :receiver_phone,
			:provider_id, :provider_name, :receiver_email,
			:message,     :shoppingCart,
			:tip, :tax,   :total, :service,
			:facebook_id, :foursquare_id, :twitter,
			:status, :credit_card
			# should be removed from accessible = giver_id, giver_name, shoppingCart, status

	has_one     :redeem, 		dependent: :destroy
	has_one     :relay,  		dependent: :destroy
	belongs_to  :provider
	has_one     :sale
	has_one     :order, 		dependent: :destroy
	has_many    :gift_items, 	dependent: :destroy
	belongs_to  :giver,    		class_name: "User"
	belongs_to  :receiver, 		class_name: "User"
	#belongs_to  :payables, 		polymorphic: true

	validates_presence_of :giver_id, :receiver_name, :provider_id, :total, :credit_card, :service, :shoppingCart

	before_create :extract_phone_digits
	before_create :add_giver_name,  :if => :no_giver_name
	before_create :regifted,        :if => :regift?
	before_create :set_status
	before_create :build_gift_items

	after_create :send_notifications, :if => :transaction_approved

	default_scope where(active: true)

#/---------------------------------------------------------------------------------------------/


	def self.init(params)
		# gift = Gift.new(params[:gift])
				# add anonymous giver feature
		# if params[:gift][:anon_id]
		# 	gift.add_anonymous_giver(params[:gift][:giver_id])
		# end
		Gift.new(params[:gift])
	end

	def phone
		self.receiver_phone
	end

	def phone= phone_number
		self.receiver_phone = phone_number
	end

	def grand_total
		pre_round = self.total.to_f + self.service.to_f
		float_to_cents(pre_round.round(2))
	end

	def total
		string_to_cents super
	end

	def service
		string_to_cents super
	end



#/-----------------------------------------------Status---------------------------------------/

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

#/--------------------------------------gift credit card methods-----------------------------/

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
		if not Rails.env.test?
			sale = self.authorize_capture
			puts "SALE ! #{sale.req_json} #{sale.transaction_id} #{sale.revenue.to_f} == #{self.total}"
		else
			sale     = Sale.init self
			sale.resp_code = 1
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

#/-------------------------------------data population methods-----------------------------/

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

private

##########  shopping cart methods

	def build_gift_items
		make_gift_items ary_of_shopping_cart_as_hash
	end

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

################  data validation methods

	def add_giver_name
		if giver = User.find(self.giver_id)
			self.giver_name = giver.username
		end
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

	def send_notifications
		unless Rails.env.test?
        	self.notify_receiver
        	if self.regift_id.nil?
        		self.invoice_giver
        	end
        	Relay.send_push_notification self
        end
    end

    def transaction_approved
    	# this should be a gift status method
    	true
    	# if self.resp_code == 1
     #        puts "Transaction is approved - time to email invoice and notification - sale ID = #{self.id}"
    	# 	return true
    	# else
     #        puts "Transaction is NOT approved - sale ID = #{self.id}"
    	# 	return false
    	# end
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
#  stat           :integer
#  pay_stat       :integer
#  pay_type       :string(255)
#  pay_id         :integer
#  notified_at    :datetime
#  notified_at_tz :string(255)
#  redeemed_at    :datetime
#  redeemed_at_tz :string(255)
#  server_code    :string(255)
#

