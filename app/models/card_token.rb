class CardToken < ActiveRecord::Base
    self.table_name = "cards"

#	-------------

    validates_presence_of  :last_four, :brand, :nickname,  :user_id, :cim_token

#	-------------

	def self.build_card_token_with_hash cc_token_hsh
		card = CardToken.new
		card.nickname 	= cc_token_hsh["nickname"]
		card.user_id 	= cc_token_hsh["user_id"]
		card.last_four  = cc_token_hsh["last_four"]
		card.brand      = cc_token_hsh["brand"]
		card.token      = cc_token_hsh["token"]
		card
	end

	def token= token
		self.cim_token = token
	end

	def token
		self.cim_token
	end

	def brand= brand_str
		return  if brand_str.nil?
		brand = if brand_str == "Amex"
			"american_express"
		elsif brand_str == "MasterCard"
			"master"
		else
			brand_str.downcase
		end
		super brand
	end


end