module DemoGifts

	def self.perform
		[ 347844, 347845, 347846, 347847, 347848].each do | gift_id |
			gift = Gift.find(gift_id)
			gift.update(status: 'notified' , redeemed_at: nil, token: nil, order_num: nil)
			gift.notify(true)
		end
	end

end