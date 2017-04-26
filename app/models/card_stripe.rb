class CardStripe < ActiveRecord::Base
    self.table_name = "cards"


#	-------------

    validates_presence_of :stripe_id, :name, :zip, :brand, :csv, :month, :year, :last_four

#	-------------

	before_validation :set_nickname

	before_save :send_to_stripe

#	-------------

	has_many   :sales
	has_many   :gifts, 	:through => :sales
	has_many   :orders,	:through => :sales

	belongs_to :client
	belongs_to :partner, polymorphic: true
	belongs_to :user, autosave: true

#	-------------

	attr_accessor :error_message

	def error_message= err
		if @error_message.nil?
			@error_message = nil
		else
			@error_message += ', ' + err.to_s
		end
	end

	def error_message
		return @error_message unless @error_message.nil?
		self.errors.full_messages.join(', ')
	end

	def token_serialize
		card_hash = self.serializable_hash only: [ "nickname", "last_four" ]
		card_hash["card_id"] = self.id
		card_hash
	end

#   -------------

	def send_to_stripe
		o = OpsStripeToken.new(self.as_json, self.user)
		o.tokenize
		puts o.inspect
		puts o.to_db
		if o.success
			self.stripe_id = o.card_id
			self.stripe_user_id = o.customer_id
			self.country = o.country if o.country
			self.ccy = o.ccy if o.ccy
			self.brand = o.brand if o.brand
			self.resp_json = o.to_db
			self.active = true
		else
			self.active = false
			self.resp_json = o.to_db
			# errors.add(o.error_key.to_sym, o.error_message)
			@error_message = o.error_message
		end
	end


	def self.create_card_from_hash cc_hash
		cc_hash.stringify_keys!
		card 			= new
		card.stripe_id 	= cc_hash["stripe_id"]
		card.stripe_user_id = cc_hash["stripe_user_id"]
		card.name 		= cc_hash["name"]
		card.nickname 	= cc_hash["nickname"]
		card.zip 		= cc_hash['zip']
		card.brand 		= cc_hash["brand"]
		card.csv 		= cc_hash["csv"]
		card.month 		= cc_hash["month"]
		card.year 		= cc_hash["year"]
		card.last_four 	= cc_hash["last_four"]
        card.nickname = cc_hash["email"]
        card.origin = cc_hash["merchant_name"]
        card.user_id = cc_hash['user_id']
        card.term = cc_hash['term']
        card.amount = cc_hash['amount']
        card.ccy = 'USD' if card.amount.present?
		card
	end

   	def set_nickname
   		if self.nickname.blank?
   			self.nickname = "#{self.brand} - #{self.last_four}"
   		end
   	end


end