class GiftPurchasedSysAlert < GiftPurchasedMtAlert

#############   THIS FILE IS AN ADMIN COPY OF GiftPurchasedMtAlert
#######


#   -------------

	def get_data
		return if @data
		return "NO TARGET" if self.target.nil?
		return "TARGET IS NOT GIFT" unless self.target.kind_of?(Gift)
		gift = self.target
		return "GIFT IS NOT PURCHASE" if self.target.cat != 300

 		@data = "#{gift.merchant_name}\n"
 		@data += "#{gift.giver_name} has sent a #{gift.value_s} gift to #{gift.receiver_name}\n"

	    if gift.shoppingCart
			@data += gift.humanize_cart.join("\n") + "\n"
        end
        if gift.client && gift.client.name
			@data = " via #{gift.client.name}\n"
        end
        @data
	end

end




# gift is purchaed
# alert is called with gift as target
# init new alert
# is there a affiliate alert ?
	# get the affiliate of the gift merchant
	# find alert contacts for this alert for the affiliate
	# loop thru contacts and send the alerts
# is there a merchant alert
	# get the merchant for the gift
	# find alert contacts for this merchant
	# loop thru contacts and send the alerts
