class CardStripe < ActiveRecord::Base
    self.table_name = "cards"

    ###                 ^^
    ###  THIS CLASS WRAPS THE CARDS TABLE AND ALLOWS FOR STRIPE CARD CREATION IN THAT TABLE

#	-------------

    validates_presence_of :stripe_id, :name, :zip, :brand, :month, :year, :last_four

#	-------------

	before_create :set_nickname
	before_save :send_to_stripe

	after_commit :card_fraud_detection

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


	def self.create_card_from_hash cc_hsh
		cc_hsh.stringify_keys!
		card = new
        card.client_id = cc_hsh['client_id']
        card.partner_id = cc_hsh['partner_id']
        card.partner_type = cc_hsh['partner_type']

		card.stripe_id 	= cc_hsh["stripe_id"]
		card.stripe_user_id = cc_hsh["stripe_user_id"]
		card.name 		= cc_hsh["name"]
		card.nickname 	= cc_hsh["nickname"]
		card.zip 		= cc_hsh['zip']
		card.brand 		= cc_hsh["brand"]
		card.csv 		= cc_hsh["csv"]
		card.month 		= cc_hsh["month"]
		card.year 		= cc_hsh["year"]
		card.last_four 	= cc_hsh["last_four"]

        card.nickname = cc_hsh["email"]
        card.origin = cc_hsh["merchant_name"]
        card.user_id = cc_hsh['user_id']
        card.term = cc_hsh['term']
        card.amount = cc_hsh['amount']
        card.country = cc_hsh['country']
        if cc_hsh['country'].present?
        	card.ccy = 'CAD' if card.country == 'CA'
        	card.ccy = 'GBP' if card.country == 'GB'
	        card.ccy = 'USD' if card.ccy.nil?
	    end

		# Convert 2->4 digit year
		if (card.year.to_s.length == 2)
			# Should be correct for the next ~60 years
			card.year = "20#{card.year}"

			puts "[model CardStripe :: create_card_from_hash]  Caught and fixed 2-digit year"
			puts card.inspect
		end

		card
	end

   	def set_nickname
   		if self.nickname.blank?
   			self.nickname = "#{self.brand} - #{self.last_four}"
   		end
   	end

	def card_fraud_detection
		puts "In Fraud detections for #{self.id}"
		Resque.enqueue(CardStripeFraudDetectionJob, self.id)
	end

end