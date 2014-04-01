class GiftPromoMock < Mtmodel

	has_many :gift_promo_socials

	def gift_hsh
		gift_hsh = {}
		gift_hsh["shoppingCart"]  = self.shoppingCart
		gift_hsh["receiver_name"] = self.receiver_name
		gift_hsh["message"]       = self.message
		gift_hsh["expires_at"]    = self.expires_at
		gift_hsh
	end

	def socials
		self.gift_promo_socials
	end

	def emails
		gp_socials = self.socials.where(network: "email")
		gp_socials.map { |gp_social| gp_social.network_id }
	end	
end