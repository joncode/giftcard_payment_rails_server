module LegacyPoints


	def make_points_for gift
		PointsForSaleJob.perform gift.id
		PointsForCompletionJob.perform gift.id
		PointsForNewUserJob.perform gift.id
	end

	def perform_points_update
		Gift.where('cat > 299').find_in_batches(batch_size: 1000) do |group_ary|
			group_ary.each do |gift|
				make_points_for gift
			end
		end
	end
end