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

	has_one     :redeem, 		dependent: :destroy
	belongs_to  :provider
	has_one     :sale
	has_one     :order, 		dependent: :destroy
	has_many    :gift_items, 	dependent: :destroy
	belongs_to  :giver,    		class_name: "User"
	belongs_to  :receiver, 		class_name: "User"
	#belongs_to  :payables, 		polymorphic: true

	validates_presence_of :giver_id, :receiver_name, :provider_id, :total, :credit_card, :service, :shoppingCart

	before_save   :extract_phone_digits
	before_create :add_giver_name,  	:if => :no_giver_name
	before_create :add_provider_name,  	:if => :no_provider_name
	before_create :regifted,        	:if => :regift?
	before_create :build_gift_items
	before_create :set_statuses

	default_scope where(active: true)

#/---------------------------------------------------------------------------------------------/


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

	def set_statuses
		case self.pay_type
		when "Sale"
			set_payment_status
			set_status
		when "CreditAccount"
		when "Campaign"
		else
			set_status
		end
	end

	def set_status
		if self.receiver_id.nil?
			self.status = "incomplete"
		else
			self.status = 'open'
		end
	end

	def set_payment_status
		case self.sale.resp_code
		when 1
		  # Approved
			self.pay_stat = "charged"
		when 2
		  # Declined
			self.pay_stat = "declined"
		when 3
		  # Error
		  # duplicate transaction response subcode = 1
			if self.sale.response.response_subcode == 1
				self.pay_stat = "duplicate"
			else
				self.pay_stat = "unpaid"
			end
		when 4
		  # Held for Review
			self.pay_stat = "unpaid"
		else
		  # not a listed error code
		  	self.pay_stat = "unpaid"
		end
		set_status
	end

#/--------------------------------------gift credit card methods-----------------------------/

    def charge_card
    	self.pay_type = "Sale"
    	sale      	  = Sale.init self  # @gift
    	sale.auth_capture

    	self.sale 	  = sale
    end

#/-------------------------------------re gift db methods-----------------------------/

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

#/-------------------------------------data population methods-----------------------------/

	def remove_receiver
		self.receiver_id    = nil
		self.receiver_name  = nil
		self.facebook_id    = nil
		self.receiver_phone = nil
		self.receiver_email = nil
		self.twitter		= nil
	end

	def add_receiver receiver
		if receiver.id
			self.status 	  = 'open'
			self.receiver_id  = receiver.id
		else
		 	self.receiver_id  = nil
		 	self.status 	  = 'incomplete'
		end
		self.receiver_name  = receiver.name
		self.facebook_id    = receiver.facebook_id ? receiver.facebook_id : nil
		self.twitter        = receiver.twitter ? 	 receiver.twitter : nil
		self.receiver_phone = receiver.phone ? 		 receiver.phone : nil
		self.receiver_email = receiver.email ? 		 receiver.email : nil
	end

	def add_giver sender
		self.giver   	= sender
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

	def add_provider_name
		if provider = self.provider
			self.provider_name = provider.name
		end
	end

	def no_provider_name
		self.provider_name.nil?
	end

	def regifted
		old_gift = Gift.find(self.regift_id)
		old_gift.update_attribute(:status, 'regifted')
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

