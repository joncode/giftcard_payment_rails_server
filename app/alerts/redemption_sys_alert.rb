class RedemptionSysAlert < GiftPurchasedMtAlert

#############   THIS FILE IS AN ADMIN COPY OF GiftPurchasedMtAlert
#######

#   -------------

	def get_data
		return if @data
		return "NO TARGET" if self.target.nil?
		return "TARGET IS NOT REDEMPTION" unless self.target.kind_of?(Redemption)
		redemption = self.target
		via = ""
        if redemption.client && redemption.client.name
        	via = " via #{redemption.client.name}"
        end
		@data = "#{redemption.receiver_name} has redeemed a #{redemption.amount_s} redemption(#{redemption.paper_id})#{via}.  Status is #{redemption.status}.  Gift #{redemption.gift.paper_id}"
	end

end