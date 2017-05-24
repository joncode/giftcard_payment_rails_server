module BookingChargeCard


	def tokenize_card
		o = OpsStripeToken.new h
		o.tokenize
		o
	end

	def charge_card

		if self.stripe_id.blank? && self.stripe_user_id.blank?
			return 'Card not present'
		end

	end


	def ch
		{ 'stripe_id' => self.stripe_id, 'stripe_user_id' => self.stripe_user_id,
			'amount' => self.price_total, 'ccy' => self.ccy, 'origin' => self.hex_id,
			'email' => self.email }
	end




# b = BG.where.not(stripe_id: nil).last
# h = { 'stripe_id' => b.stripe_id, 'stripe_user_id' => b.stripe_user_id, 'amount' => b.price_total, 'ccy' => b.ccy, 'origin' => b.hex_id, 'email' => b.email }






end