class Card < ActiveRecord::Base
	#include ActiveMerchant::Billing::CreditCardMethods
	#include ActiveMerchant::Billing::CreditCardMethods::ClassMethods
	
	attr_accessible :csv, :last_four, :month, :name, :nickname, :
	number_digest, :type, :user_id, :year

	validates_presence_of :csv, :last_four, :month, :name, :nickname, :number_digest, :type, :user_id, :year

  	has_many   :sales
	belongs_to :user
	has_many   :gifts, 	through: :sales
	has_many   :orders,	through: :sales
		
	before_validation :convert_number_to_string
	before_save 	  :encrypt_number
	before_save :save_last_four_digits
	
	def last_four
		new_record? ? save_last_four_digits : read_attribute(:last_four_digits)
	end

	# Gets the first name from name
	def first_name
		name.split[0] if name
	end

	# Gets the last name from name
	def last_name
		name.split[1..-1].join(" ") if name
	end

	private


		def check_for_credit_card_validity
			errors.add(:year, "is not a valid year") unless valid_expiry_year?(year.to_i)
			errors.add(:month, "is not a valid month") unless valid_month?(month.to_i)
			errors.add(:number, "is not a valid credit card number") unless valid_number?(number)
			self.card_type = type?(number)
			errors.add_to_base("We only accept Visa and MasterCard.") unless self.card_type == 'master' or self.card_type == 'visa'
		end

		def month_and_year_should_be_in_future
			if (Date.new(year.to_i, month.to_i, 1) >> 1) < Date.today
			 errors.add_to_base("The expiration date must be in the future.") and return false
			end
			rescue ArgumentError => e
			errors.add_to_base("Date is not valid") and return false
		end

		def at_least_two_words_in_name
			errors.add(:name, "must be two words long.") and return false if name and name.split.size < 2
		end


		def save_last_four_digits
			self.last_four_digits = @number[-4..-1]
		end

		# Encrypts the credit card number
		def encrypt_number
			c = cipher
			c.encrypt
			c.key = key 
			temp_number = c.update(@number)
			temp_number << c.final
			self.number_digest = encode_into_base64(temp_number) 
		end

		def key
			Digest::SHA256.digest(@@CreditCardSecretKey)
		end

		def convert_number_to_string
	   		@number = @number.to_s
	   	end
end

