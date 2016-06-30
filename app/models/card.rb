class Card < ActiveRecord::Base
	extend CardTesters
	include CardTokenizer
 	include ActiveMerchant::Billing::CreditCardMethods
	include ActiveMerchant::Billing::CreditCardMethods::ClassMethods

	@@CreditCardSecretKey = CCS_KEY
	PASSPHRASE 		 	  = CATCH_PHRASE

	default_scope -> { where(active: true) } # indexed

#	-------------

 	before_validation :convert_number_to_string
	before_validation :save_last_four

#   -------------

	validate :check_for_credit_card_validity
	validate :month_and_year_should_be_in_future
	validate :at_least_two_words_in_name
	validates_presence_of :csv, :last_four, :month, :year, :nickname,  :user_id, :name
	validates :zip, zip_code: true, allow_blank: true

#   -------------

	before_create :send_to_stripe
	before_save :crypt_number
	after_create :tokenize_card

#	-------------

	has_many   :sales
	has_many   :gifts, 	:through => :sales
	has_many   :orders,	:through => :sales
	belongs_to :user, autosave: true
	belongs_to :client
	belongs_to :partner, polymorphic: true

#   -------------

	def send_to_stripe
		if self.stripe_id
			return true
		end
		card_owner = self.user
		customer_id = card_owner.stripe_id
		o = OpsStripeCard.new(customer_id, self)
		o.add_customer = card_owner
		r = o.tokenize
		puts o.inspect
		# add stripe data to card & user
		if customer_id.nil?
			self.user.stripe_id = o.customer_id
		end
		self.stripe_id = o.card_id
		self.stripe_user_id = o.customer_id || customer_id
		self.country = o.country if o.country
		self.ccy = o.ccy if o.ccy
		self.brand = o.brand if o.brand
		self.resp_json = o.to_db
		unless o.success
			# didnt work
			# error
			self.active = false
			errors.add(o.error_key.to_sym, o.error_message)
			# return false
		end

	end

	def response
		JSON.parse self.resp_json
	rescue
		nil
	end

	attr_accessor :iv

	def destroy
			# must delete auth.net record
		#log_bars "card.destroy -> Use controllers/concerns/cim_profile :destroy_card(card, user)"
		update_column(:active, false)
	end

	def expired?
		t = DateTime.now.utc
		ex_year = self.year.to_i
		ex_month = self.month.to_i
		if t.year > ex_year  # card expired before this year
			return true
		elsif t.year == ex_year && t.month > ex_month  # card expired this year before this month
			return true
		else
			return false
		end
	end

	def update_with_duplicate_cim_token
		c2 = Card.where(number_digest: self.number_digest,
					month: self.month,
					csv: self.csv,
					year: self.year).where.not(cim_token: nil).first
		if c2
			self.update_column(:cim_token, c2.cim_token)
		end
	end

#	-------------

	def self.get_cards user
		cards = where(user_id: user.id)
		cards.map { |card| {"card_id" => card.id, "last_four" => card.last_four, "nickname" => card.nickname} }
	end

	def self.create_card_from_hash cc_hash
		card 			= new
		card.user_id 	= cc_hash["user_id"]
		card.name 		= cc_hash["name"]
		card.month 		= cc_hash["month"]
		card.year 		= cc_hash["year"]
		card.nickname 	= cc_hash["nickname"]
		card.csv 		= cc_hash["csv"]
		card.brand 		= cc_hash["brand"]
		card.number 	= cc_hash["number"]
		card.zip 		= cc_hash['zip']
		card
	end

#	-------------

    def sale_hsh card_amount, ccy, unique_id, cim_profile=nil, merchant_id
	    hsh = {}
	    hsh["amount"] = card_amount
	    hsh['ccy'] = ccy
	    hsh["unique_id"] = unique_id #if args["unique_id"]
	    hsh["card_id"] = self.id
	    hsh["giver_id"] = self.user_id
	    hsh["merchant_id"] = merchant_id
	    if self.stripe_id
	    	hsh['stripe_id'] = self.stripe_id
	    	hsh['stripe_user_id'] = self.stripe_user_id
	    	return hsh
    	elsif self.cim_token
	    	if hsh["cim_profile"] = (cim_profile || self.user.cim_profile)
	    		hsh["cim_token"]  = self.cim_token
				return hsh
			end
    	end
    	self.decrypt!(PASSPHRASE)
    	hsh["number"]  		= self.number
    	hsh["month_year"] 	= self.month_year
    	hsh["first_name"]   = self.first_name
    	hsh["last_name"] 	= self.last_name
	    hsh
    end


    	# deprecate this function
	def create_serialize
		card_hash = self.serializable_hash only: [ "id", "nickname", "last_four" ]
		card_hash["card_id"] = self.id
		card_hash
	end

	def token_serialize
		card_hash = self.serializable_hash only: [ "nickname", "last_four" ]
		card_hash["card_id"] = self.id
		card_hash
	end

#	-------------

	def number
		@number
	end

	def number=(number)
		@number = number
	end

	def month_year
		month 		 = "%02d" % self.month.to_i
		year 		 = self.year[2..3]
		"#{month}#{year}"
	end

	def first_name
		name.split[0] if name
	end

	def last_name
		name.split[1..-1].join(" ") if name
	end

	def verification_value?
       	false
    end

	def decrypt!(passphrase)
        @number = decrypt_number(passphrase)
        self
    end

	def last_four
		new_record? ? save_last_four : read_attribute(:last_four)
	end

private

	def tokenize_card
		if (Rails.env.staging? || Rails.env.production?)
            Resque.enqueue(CardTokenizerJob, self.id)
        end
	end

	def check_for_credit_card_validity
		errors.add(:year, "is not a valid year") unless valid_expiry_year?(year.to_i)
		errors.add(:month, "is not a valid month") unless valid_month?(month.to_i)
		errors.add(:number, "is not a valid credit card number") unless valid_number?(number)
		# self.brand = brand?(number)
		# errors.add(:brand, "We only accept AmEx, Visa, & MasterCard.") unless (self.brand == 'master' || self.brand == 'visa' || self.brand == 'american_express')
		#puts "error messages = #{errors.messages}"
	end

	def month_and_year_should_be_in_future
		if (Date.new(year.to_i, month.to_i, 1) >> 1) < Date.today
		 errors.add(:expiration,"The expiration date must be in the future.") and return false
		end
		rescue ArgumentError => e
		errors.add(:expiration,"Date is not valid") and return false
	end

	def at_least_two_words_in_name
		errors.add(:name, "must be two words long.") and return false if name and name.split.size < 2
	end


	def save_last_four
		self.last_four = Card.last_digits(@number)
	end

	# Encrypts the credit card number
	def crypt_number
	    c = cipher
	    c.encrypt
	    c.key = key
	    c.iv = self.iv = generate_iv(PASSPHRASE)
	    temp_number = c.update(@number)
	    temp_number << c.final
	    self.number_digest = encode_into_base64(temp_number)
	end

	# Decrypts the credit card number
	def decrypt_number(passphrase)
		@passphrase = passphrase
		c = cipher
		c.decrypt
		c.key = key
		c.iv = generate_iv(passphrase)
		d = c.update(decode_from_base64(self.number_digest))
		d << c.final
	end

	   # Chomping is necessary for postgresql
	def encode_into_base64 string
	  	Base64.encode64(string).chomp
	end

	def decode_from_base64 string
	  	Base64.decode64(string)
	end

	def cipher
		OpenSSL::Cipher::Cipher.new("aes-256-cbc")
	end

	def key
		Digest::SHA256.digest(@@CreditCardSecretKey)
	end

	def generate_iv(passphrase)
		encode_into_base64(Digest::SHA1.hexdigest(passphrase))
	end

	def convert_number_to_string
   		@number     = @number.to_s
   	end
end

# == Schema Information
#
# Table name: cards
#
#  id            :integer         not null, primary key
#  user_id       :integer
#  nickname      :string(255)
#  name          :string(255)
#  number_digest :string(255)
#  last_four     :string(255)
#  month         :string(255)
#  year          :string(255)
#  csv           :string(255)
#  brand         :string(255)
#  created_at    :datetime        not null
#  updated_at    :datetime        not null
#  cim_token     :string(255)
#  zip           :string(255)
#

