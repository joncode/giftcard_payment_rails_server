class CardStripe < ActiveRecord::Base
    self.table_name = "cards"


#	-------------


    validates_presence_of :stripe_id, :name, :zip, :brand, :csv, :month, :year, :last_four

#	-------------

	before_save :send_to_stripe

#	-------------


	belongs_to :client
	belongs_to :partner, polymorphic: true

#	-------------

	def send_to_stripe
		o = OpsStripeToken.new(self.as_json)
		o.tokenize
		if o.success
			self.stripe_id = o.card_id
			self.stripe_user_id = o.customer_id
			self.country = o.country if o.country
			self.ccy = o.ccy if o.ccy
			self.brand = o.brand if o.brand
			self.resp_json = o.to_db
		else
			self.resp_json = o.error.as_json
		end
	end


	def self.create_card_from_hash cc_hash
		cc_hash.stringify_keys!
		card 			= new
		card.stripe_id 	= cc_hash["stripe_id"]
		card.stripe_user_id = cc_hash["stripe_user_id"]
		card.name 		= cc_hash["name"]
		card.zip 		= cc_hash['zip']
		card.brand 		= cc_hash["brand"]
		card.csv 		= cc_hash["csv"]
		card.month 		= cc_hash["month"]
		card.year 		= cc_hash["year"]
		card.last_four 	= cc_hash["last_four"]
		card
	end




end