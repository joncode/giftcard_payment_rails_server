class PointsForNewUserJob

    @queue = :leaderboard

    def self.perform gift_id
		gift       = Gift.includes(:giver).includes(:provider).find gift_id
    	return  if gift.cat < 300
    	return  if gift.receiver_id.nil?
		user       = gift.giver
		provider   = gift.provider
		region_id  = provider.region_id

		user_point = UserPoint.find_or_initialize_by(region_id: region_id, user_id: user.id)
		event_points = 0

		if gift.receiver && gift.created_at < gift.receiver.created_at
			user_point.add_points(5000)
		end

    end

end