class PointsForCompletionJob

    @queue = :leaderboard

    def self.perform gift_id
		gift       = Gift.includes(:giver).includes(:merchant).find gift_id
    	puts "Gift for PointsForCompletionJob \n #{gift.id}"

    	return  if gift.cat < 300
        return  if gift.giver_type != "User"
		return  unless ["redeemed", "regifted"].include?(gift.status)
		return  if gift.redeemed_at.nil?

		if gift.status == 'regifted'
			new_g = gift.child
			return if ( new_g && new_g.giver_type != "User" )
		end
		return if gift.giver_id == gift.receiver_id

		user       = gift.giver
		return if user.nil?

		merchant   = gift.merchant
		region_id  = merchant.region_id

		user_point = UserPoint.find_or_initialize_by(region_id: region_id, user_id: user.id)
		event_points = user_point.completion_points_for_gift(gift)

		user_point.add_points(event_points)
    end

end

	# gift.redeem_gift calls pointsforcompleteJob gift_id

	# return  if gift.cat < 300
	# return  if gift.status != ["redeemed", "regifted"]

	# gift        = Gift.includes(:user).includes(:provider).find gift_id

	# user        = gift.giver
	# provider    = gift.provider
	# region_id   = provider.region_id

	# user_point  = UserPoint.find_or_intialize_by(region_id: region_id, user_id: user.id)
	# event_point = 0
	# delay       = gift.redeemed_at - gift.created_at

	# def calculate_points
	# 	points_ary = if gift.status == 'redeemed'
	# 		[10000,3000,1500]
	# 	else
	# 		[3000,1000,500]
	# 	end
	# 	event_point = if 7.days > delay
	# 		points_ary[0]
	# 	elsif 31.days > delay
	# 		points_ary[1]
	# 	else
	# 		points_ary[2]
	# 	end
	# end

	# points =  event_point + user_point.points
	# UserPoint.add_points_to_total(user_id: user.id, points: event_point)
	# user_point.save