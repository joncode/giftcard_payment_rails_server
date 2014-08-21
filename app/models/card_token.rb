class CardToken < ActiveRecord::Base
	self.table_name = "cards"
 	include ActiveMerchant::Billing::CreditCardMethods
	include ActiveMerchant::Billing::CreditCardMethods::ClassMethods

	has_many   :sales, as: :card
	belongs_to :user
	has_many   :gifts, 	:through => :sales
	has_many   :orders,	:through => :sales

#	-------------

	validate :check_for_credit_card_validity
	validate :month_and_year_should_be_in_future
	validate :at_least_two_words_in_name

	validates_presence_of :profile_id, :payment_profile_id, :month, :year, :brand, :nickname, :user_id, :name

#	-------------

    def create_card_hsh args
    	self.decrypt!(PASSPHRASE)
    	hsh = {}
        hsh["card_id"]      = self.id
    	hsh["month_year"] 	= self.month_year
    	hsh["first_name"]   = self.first_name
    	hsh["last_name"] 	= self.last_name
    	hsh["amount"] 		= args["amount"]
    	hsh["unique_id"]	= args["unique_id"] if args["unique_id"]
    	hsh
    end

	def create_serialize
		card_hash = self.serializable_hash only: [ "id", "nickname", "last_four" ]
		card_hash["card_id"] = self.id
		card_hash
	end

	def self.create_card_from_hash cc_hash
		card 			= Card.new
		card.name 		= cc_hash["name"]
		card.month 		= cc_hash["month"]
		card.year 		= cc_hash["year"]
		card.nickname 	= cc_hash["nickname"]
		card.user_id 	= cc_hash["user_id"]
		card.brand 		= cc_hash["brand"]
		card
	end
	
	def self.get_cards user
		cards = Card.where(user_id: user.id)
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

private


	def check_for_credit_card_validity
		errors.add(:year, "is not a valid year") unless valid_expiry_year?(year.to_i)
		errors.add(:month, "is not a valid month") unless valid_month?(month.to_i)
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

