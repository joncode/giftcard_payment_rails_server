class DailyAnalyticsCreator

	attr_reader :created, :admin, :merchant, :campaign, :purchased, :regifted, :cregifted, :boomerang, :notified, :redeemed,
				:other, :completed, :velocity, :expired, :revenue_pennies ,:profit_pennies, :retail_v

	def self.first_day
		Gift.first.created_at.to_date - 1.day
	end

	def initialize(date)
		yesterday       = date
		start_time      = yesterday.to_datetime.beginning_of_hour.change(hour: 14)
		end_time        = start_time + 24.hours
		@created_gifts  = Gift.where(created_at:  [ start_time...end_time])
		@notified_gifts = Gift.where(notified_at: [ start_time...end_time])
		@redeemed_gifts = Gift.where(redeemed_at: [ start_time...end_time])
		@created        = @created_gifts.count
		@admin          = 0
		@merchant       = 0
		@campaign       = 0
		@purchased      = 0
		@boomerang      = 0
		@other          = 0
		@regifted       = 0
		@notified       = @notified_gifts.count
		@redeemed       = @redeemed_gifts.select {|g| g.status == 'redeemed'}.count
		@expired        = @redeemed_gifts.select {|g| g.status == 'expired'}.count
		@cregifted      = @redeemed_gifts.select {|g| g.status == 'regifted'}.count
		@completed      = @redeemed_gifts.count
		@velocity       = @completed + @notified + @created
		@revenue_pennies = 0
		@profit_pennies  = 0
		@retail_v        = 0
	end

	def get_numbers
		@created_gifts.each do |g|
			case g.cat
			when 300
				@purchased += 1
				@revenue_pennies += g.value_f + g.service.to_f
				@profit_pennies  += -g.fee
				@retail_v += g.value_f
			when 307
				@boomerang += 1
			when 100
				@admin 	+= 1
			when 200
				@merchant += 1
			when 150, 250
				@campaign += 1
			when 101 , 151 , 201 , 251 , 301
				@regifted += 1
			else
				@other += 1
			end
		end
	end

end


		# @gifts_created = 10
 	# 	@gifts_admin = 10
 	# 	@gifts_merchant = 10
 	# 	@gifts_campaigns = 10
		# @gifts_purchased = 23
 	# 	@gifts_regifted = 3
 	# 	@gifts_boomerangs = 34
 	# 	@gifts_notified = 123
 	# 	@gifts_redeemed = 66