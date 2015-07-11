class PointsForSaleJob

    @queue = :leaderboard

    def self.perform gift_id
		gift       = Gift.includes(:giver).includes(:merchant).find gift_id
        puts "Gift for PointsForSaleJob \n #{gift.inspect}"
    	return  if gift.cat < 300
    	return  if gift.giver_type != "User"

		user       = gift.giver
		return if user.nil?
		provider   = Merchant.unscoped.find(gift.merchant_id)
		region_id  = provider.region_id

		user_point = UserPoint.find_or_initialize_by(region_id: region_id, user_id: user.id)
		event_points = 0

		event_points += (gift.value.to_f * 100).to_i

		if gift.facebook_id.present? || gift.twitter.present?
			event_points += 1000
		end
		user_point.add_points(event_points)
    end

end



