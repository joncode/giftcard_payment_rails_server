class Card < ActiveRecord::Base
 	include ActiveMerchant::Billing::CreditCardMethods
	include ActiveMerchant::Billing::CreditCardMethods::ClassMethods

	@@CreditCardSecretKey = CCS_KEY
	PASSPHRASE 		 	  = CATCH_PHRASE

	attr_accessor :iv

	has_many   :sales
	belongs_to :user
	has_many   :gifts, 	:through => :sales
	has_many   :orders,	:through => :sales

#	-------------

 	before_validation :convert_number_to_string
	before_validation :save_last_four

	validate :check_for_credit_card_validity
	validate :month_and_year_should_be_in_future
	validate :at_least_two_words_in_name

	validates_presence_of :csv, :last_four, :month, :year, :brand, :nickname,  :user_id, :name

	before_save :crypt_number

#	-------------

    def charge amount
        puts "CHARGING CARD\n"
        sale = Sale.new
        sale.revenue  = amount
        sale.card     = self
        sale.giver_id = self.user_id
        sale.resp_code = 1
        sale
    end

	def create_serialize
		card_hash = self.serializable_hash only: [ "id", "nickname", "last_four" ]
	end

	def number
		@number
	end

	def number=(number)
		@number = number
	end

	def self.create_card_from_hash cc_hash
		card 			= Card.new
		card.name 		= cc_hash["name"]
		card.month 		= cc_hash["month"]
		card.year 		= cc_hash["year"]
		card.nickname 	= cc_hash["nickname"]
		card.csv 		= cc_hash["csv"]
		card.user_id 	= cc_hash["user_id"]
		card.brand 		= cc_hash["brand"]
		card.number 	= cc_hash["number"]
		card
	end

	def self.get_cards user
		cards = Card.find_all_by_user_id(user.id)
		cards.map { |card| {"card_id" => card.id, "last_four" => card.last_four, "nickname" => card.nickname} }
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


	def check_for_credit_card_validity
		errors.add(:year, "is not a valid year") unless valid_expiry_year?(year.to_i)
		errors.add(:month, "is not a valid month") unless valid_month?(month.to_i)
		errors.add(:number, "is not a valid credit card number") unless valid_number?(number)
		self.brand = brand?(number)
		errors.add(:brand, "We only accept AmEx, Visa, & MasterCard.") unless (self.brand == 'master' || self.brand == 'visa' || self.brand == 'american_express')
		puts "error messages = #{errors.messages}"
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
#

