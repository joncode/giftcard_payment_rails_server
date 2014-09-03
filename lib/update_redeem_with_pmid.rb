module UpdateRedeemWithPmid

	def self.perform
		redeems = Redeem.where(pos_merchant_id: nil)
		redeems.each do |redeem|
			if redeem.gift && redeem.gift.provider
				pmid = redeem.gift.provider.pos_merchant_id
				redeem.update(pos_merchant_id: pmid)
			end
		end
	end

end
