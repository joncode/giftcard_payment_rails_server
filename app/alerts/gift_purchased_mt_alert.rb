class GiftPurchasedMtAlert < Alert

	def note
		self.target.merchant
	end

#   -------------

	def text_msg
		get_data
		"#{name_string}\n#{@data}"
	end

	def email_msg
		get_data
		"<div><h2>#{name_string}</h2><p>#{@data}</p></div>".html_safe
	end

	def msg
		text_msg
	end

#   -------------

	def get_data
		return if @data
		return "NO TARGET" if self.target.nil?
		return "TARGET IS NOT GIFT" unless self.target.kind_of?(Gift)
		gift = self.target
		return "GIFT IS NOT PURCHASE" if self.target.cat != 300
	    if gift.shoppingCart
            items = gift.ary_of_shopping_cart_as_hash
            items = items.map do |item|
                "#{item["quantity"]} x #{item["item_name"]}"
            end
            items = "of " + items.join(',')
        end
		@data = "#{gift.giver_name} has sent a #{gift.value_s} gift #{items}\
 at #{gift.provider_name} to #{gift.receiver_name}"
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
