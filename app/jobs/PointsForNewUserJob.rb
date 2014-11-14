class PointsForNewUserJob

    @queue = :leaderboard

    def self.perform gift_ary_or_id

    	if gift_ary_or_id.kind_of?(Array) || gift_ary_or_id.kind_of?(Gift::ActiveRecord_Relation)
    		gifts = gift_ary_or_id.select do |gift|
    			( gift.cat > 299 ) && ( gift.receiver_id.present? )
    		end
    		return if gifts.count == 0

    		gift = gifts.first
    		gifts.each do |g|
    			if gift.created_at > g.created_at
    				gift = g
    			end
    		end
    	else
			gift  = Gift.includes(:giver).includes(:provider).find(gift_ary_or_id)

		end
        return  if gift.cat < 300
        return  if gift.giver_type != "User"
        return  if gift.receiver_id.nil?

		if gift.receiver && gift.created_at < gift.receiver.created_at
			older_gift = Gift.where(receiver_id: gift.receiver_id).limit(1).first
			if gift == older_gift
				user       = gift.giver
				provider   = gift.provider
				region_id  = provider.region_id
				user_point = UserPoint.find_or_initialize_by(region_id: region_id, user_id: user.id)
				user_point.add_points(5000)
			end
		end
    end
end
