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

class Card < ActiveRecord::Base
	include ActiveMerchant::Billing::CreditCardMethods
	include ActiveMerchant::Billing::CreditCardMethods::ClassMethods
	
	@@CreditCardSecretKey = "Yes yes yes"
	PASSPHRASE = "Theres no place like home"
	attr_accessor :number, :passphrase, :iv
	attr_accessible :csv, :last_four, :month, :brand, :name, :nickname,  :user_id, :year

	validates_presence_of :csv, :last_four, :month, :brand, :name, :nickname,  :user_id, :year
	validates_presence_of  :number

	validate :check_for_credit_card_validity
	validate :month_and_year_should_be_in_future
	validates_presence_of :passphrase
  	
  	has_many   :sales
	belongs_to :user
	has_many   :gifts, 	through: :sales
	has_many   :orders,	through: :sales
		
	before_validation :convert_number_to_string
	before_save 	  :crypt_number
	before_save 	  :save_last_four
	
	def self.create_card_from_hash cc_hash
		puts "in create_card_from_hash"
		card = Card.new
		card.name = cc_hash["name"]
		card.month = cc_hash["month"]
		card.year = cc_hash["year"]
		card.nickname = cc_hash["nickname"]
		card.csv = cc_hash["csv"]
		card.user_id = cc_hash["user_id"]
		card.brand = cc_hash["brand"]
		card.number = cc_hash["number"]
		card.passphrase = cc_hash["nickname"]
		puts "making a new card = #{card.inspect}"
		return card
	end

	def self.get_cards user
		cards = Card.find_all_by_user_id(user.id)
		display_cards = []
		cards.each do |card|
			card_hash = {"card_id" => card.id, "last_four" => card.last_four, "nickname" => card.nickname}
			display_cards << card_hash
		end
		return display_cards
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

	# Gets the first name from name
	def first_name
		name.split[0] if name
	end

	# Gets the last name from name
	def last_name
		name.split[1..-1].join(" ") if name
	end

	def number
		@number
	end

	def number=(number)
		@number = number	
	end

	private


		def check_for_credit_card_validity
			errors.add(:year, "is not a valid year") unless valid_expiry_year?(year.to_i)
			errors.add(:month, "is not a valid month") unless valid_month?(month.to_i)
			errors.add(:number, "is not a valid credit card number") unless valid_number?(number)
			puts "error messages = #{errors.messages}"
			self.brand = brand?(number)
			errors.add(:base, "We only accept Visa and MasterCard.") unless self.brand == 'master' or self.brand == 'visa'
		end

		def month_and_year_should_be_in_future
			if (Date.new(year.to_i, month.to_i, 1) >> 1) < Date.today
			 errors.add(:base,"The expiration date must be in the future.") and return false
			end
			rescue ArgumentError => e
			errors.add(:base,"Date is not valid") and return false
		end

		def at_least_two_words_in_name
			errors.add(:name, "must be two words long.") and return false if name and name.split.size < 2
		end


		def save_last_four
			self.last_four = @number[-4..-1]
		end

		# Encrypts the credit card number
		def crypt_number
		    c = cipher
		    c.encrypt
		    c.key = key 
		    c.iv = self.iv = generate_iv(passphrase)
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
			passphrase = PASSPHRASE
			raise ArgumentError.new("be sure to set the passphrase") if passphrase.blank?
			encode_into_base64(Digest::SHA1.hexdigest(passphrase))
		end

		def convert_number_to_string
			@passphrase = @passphrase.to_s
	   		@number = @number.to_s
	   	end
end

