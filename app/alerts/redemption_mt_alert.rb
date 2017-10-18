class RedemptionMtAlert < GiftPurchasedMtAlert

#############   THIS FILE IS AN ADMIN COPY OF GiftPurchasedMtAlert
#######

#   -------------

	def get_data
		return if @data
		return "NO TARGET" if self.target.nil?
		return "TARGET IS NOT REDEMPTION" unless self.target.kind_of?(Redemption)
		redemption = self.target
		@data = "#{redemption.receiver_name} has redeemed a #{redemption.amount} redemption. Status = #{redemption.status}"
	end

end