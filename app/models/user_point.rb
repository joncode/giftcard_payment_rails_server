class UserPoint < ActiveRecord::Base

	validates :region_id, :uniqueness => { scope: :user_id }
	belongs_to :user

	after_save :add_points_to_total

	def add_points(points)
		@added_points = points.to_i
		self.points   +=  @added_points
		self.save
	end

	def completion_points_for_gift gift
		delay       = gift.redeemed_at - gift.created_at
		points_ary = if gift.status == 'redeemed'
			[10000,3000,1500]
		else
			[3000,1000,500]
		end
		if 7.days > delay
			points_ary[0]
		elsif 31.days > delay
			points_ary[1]
		else
			points_ary[2]
		end
	end

private

	def add_points_to_total
		if self.region_id != 0 && @added_points.to_i > 0
			total_record = UserPoint.find_or_initialize_by(region_id: 0, user_id: self.user_id)
			total_record.add_points(@added_points)
		end
	end

end
# == Schema Information
#
# Table name: user_points
#
#  id         :integer         not null, primary key
#  user_id    :integer
#  region_id  :integer         default(0)
#  points     :integer         default(0)
#  created_at :datetime
#  updated_at :datetime
#

