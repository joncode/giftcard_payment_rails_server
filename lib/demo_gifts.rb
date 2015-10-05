module DemoGifts

	def self.perform
		puts "DEMOGIFT scheduler"
		[ 347844, 347845, 347846, 347847, 347848].each do | gift_id |
			gift = Gift.find(gift_id)
			if gift.status == 'redeemed'
				gift.update(status: 'notified' , redeemed_at: nil, order_num: nil)
			end
			gift.notify(true)
		end
	end

end