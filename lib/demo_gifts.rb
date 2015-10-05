module DemoGifts

	def self.perform
		puts "DEMOGIFT scheduler"
		[ 347844, 347845, 347846, 347847, 347848].each do | gift_id |
			gift = Gift.find(gift_id)
			gift.unredeem
			gift.notify(true)
		end
	end

end