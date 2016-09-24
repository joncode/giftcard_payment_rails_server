class License < ActiveRecord::Base
	# 	might be based on live date of the contract, might be based on live date of the locations

	# note -  text field to dump the results of each successful register request

	TODAY = DateTime.now.utc.to_date

	# ENUM :status  'live', 'expired', 'cancel', 'inactive'
	# ENUM :recurring_type 'monthly', 'annual'
	# ENUM :origin  'subscription', 'promo'
	# ENUM :amount_action  'single', 'multiple' , 'variable_merchant', 'variable_redemption'

#   -------------

	belongs_to :partner

#   -------------

	def self.get_live
		where(status: 'live')
	end

#   -------------

	def count_merchants
		Merchant.count_for_affiliate(partner.id)
	end

	def count_redemptions
		Redemption.count_promo_redemptions_for(partner, start_date, end_date)
	end

	def total_promo_redemptions
		Redemption.total_promo_redemptions_for(partner, start_date, end_date)
	end

#   -------------

	def ccy
		self.ccy || 'USD'
	end

	def charge_amount
		return @charge_amount if @charge_amount
		@charge_amount = case self.amount_action
		when 'variable_merchant'
			(count_merchants * self.amount)
		when 'variable_redemption'
			(total_promo_redemptions * self.percent) # round up / down ??
		else
			self.amount
		end
	end

	def charge_object
		charge_object = {}
		charge_object[:partner_type] = self.partner_type
		charge_object[:partner_id] = self.partner_id
		charge_object[:type] = 'debt'
		charge_object[:origin] = self.origin
		charge_object[:amount] = charge_amount
		charge_object[:ccy] = ccy
		charge_object[:license_id] = self.id
		charge_object[:name] = line_item_name
		charge_object[:detail] = line_item_detail
		charge_object
	end

#   -------------

	def start_date
		return @start_date if @start_date

		@start_date = case self.recurring_type
			when 'monthly'
				(DateTime.now.utc.beginning_of_month - 1.month).to_date
			when 'annual'
				self.live_at.to_date
			end
	end

	def end_date
		return @end_date if @end_date

		@end_date = case self.recurring_type
			when 'monthly'
				DateTime.now.utc.beginning_of_month.to_date
			when 'annual'
				self.expires_at.to_date
			end
	end

#   -------------

	def line_item_name
		self.name
	end

	def line_item_detail
		d = self.detail
		case self.detail_action
		when 'count_redemptions'
			x = count_redemptions
		when 'count_merchants'
			x = count_merchants
		end
		if x
			d = x.to_s + ' ' + d
			d.gsub!(/s$/, '') if x == 1
		end
		d
	end

#   -------------

	def make_register_today?
		case self.recurring_type
		when 'monthly'
			dd = TODAY.day - (self.process_day || 5)
			weekday = self.weekday || 'monday'
			if (0...7).cover?(dd) && TODAY.send("#{weekday}?")
				# if todays date minus the process date is 0+ but less than 7 - in correct week
				#  and today is the weekday
				return true
			else
				return false
			end
		when 'annual'
			return (TODAY.month == self.live_date.month && TODAY.day == self.live_date.day)
		else
			return false
		end
	end

end

#<Register id: 8659, gift_id: 362204, amount: 900, partner_id: 75, partner_type: "Merchant",
# origin: 1, type_of: 0, created_at: "2016-09-13 18:43:05", updated_at: "2016-09-13 18:43:05",
# payment_id: nil, ccy: "USD">


# reg = new
# reg.partner_type = charge_object[:partner_type]
# reg.partner_id = charge_object[:partner_id]
# reg.type_of = charge_object[:type] # charge / refund
# reg.origin = charge_object[:origin]
# reg.amount = charge_object[:amount]
# reg.ccy = charge_object[:ccy]
# reg.license_id = charge_object[:license_id]
# reg.note = charge_object[:note]
# reg


# --------------------------------------------------------------------

# Wolfgang Puck License
#  	fixed monthly subscription fees , compounding licenses


# id: '238ry1f-23fg12-12312',
# status: 'live',
# partner_id: 56,
# partner_type: 'Affiliate',
# live_date: '10/01/2016',
# end_date: '10/01/2017',
# origin: 'subscription',
# response: {
# 	line_item: {
# 		name: 'Subscription Fee',
# 		detail: '%@ locations',
# 		detail_action: 'count_merchants'
# 	}
# 	payment_date: {
# 		recurring_type: 'monthly',
# 		process_day: 5,
# 		weekday: 'monday',
# 		notify_day: 2,
# 		charge_type: 'Card',
# 		charge_id: 234 # card.id
# 	}
# 	amount: {
# 		cents: 4000,
# 		ccy: "USD",
# 		type: 'variable_merchant'
# 	}
# }


# id: '13851y24-1237891-123',
# status: 'live',
# partner_id: 56,
# partner_type: 'Affiliate',
# live_date: '10/01/2016',
# end_date: '10/01/2017',
# origin: 'promo',
# response: {
# 	line_item: {
# 		name: 'Promotions Fee',
# 		detail: '%@ promotional gift redemptions',
# 		detail_action: 'count_redemptions'
# 	}
# 	payment_date: {
# 		recurring_type: 'monthly',
# 		process_day: 5,
# 		weekday: 'monday',
# 		notify_day: 2,
# 		charge_type: 'credit_card',
# 		charge_id: 234 # card.id
# 	}
# 	amount: {
# 		percentage: 0.05,
# 		ccy: "USD",
# 		type: 'variable_redemption'
# 	}
# }

# --------------------------------------------------------------------

# GolfNow License
# 	fixed monthly subscription fees , compounding licenses

# id: '4534q5-439fy189-234',
# status: 'live',
# partner_id: 31,
# partner_type: 'Affiliate',
# live_date: '2/01/2016',
# end_date: '2/01/2017',
# auto_renew: false,
# origin: 'subscription',
# response: {
# 	line_item: {
# 		name: 'Subscription Fee',
# 		detail: '300 golf courses'
# 	}
# 	payment_date: {
# 		recurring_type: 'annual',
# 		process_day: 5,
# 		weekday: 'monday',
# 		notify_day: 2,
# 		charge_type: 'check',
# 		charge_id: nil
# 	}
# 	amount: {
# 		cents: 7500000,
# 		ccy: "USD",
# 		type: 'multiple',
# 		units: 300
# 	}
# }

# id: '9234fg23-23yf9g3-2hg3f71',
# status: 'live',
# partner_id: 31,
# partner_type: 'Affiliate',
# live_date: '2/01/2016',
# end_date: '2/01/2017',
# auto_renew: false,
# origin: 'subscription',
# response: {
# 	line_item: {
# 		name: 'Subscription Fee',
# 		detail: '100 golf courses - tier 2'
# 	}
# 	payment_date: {
# 		recurring_type: 'annual',
# 		process_month: 2,
# 		process_day: 1,
# 		charge_type: 'check',
# 		charge_id: nil
# 	}
# 	amount: {
# 		cents: 2500000,
# 		ccy: "USD",
# 		type: 'multiple',
# 		units: 100
# 	}
# }

# --------------------------------------------------------------------

# Border Grill
# 	variable monthly subscription fees

# id: '238ry1f-23fg12-12312',
# status: 'live',
# partner_id: 22,
# partner_type: 'Affiliate',
# live_date: '6/01/2016',
# end_date: '6/01/2017',
# origin: 'subscription',
# response: {
# 	line_item: {
# 		name: 'Subscription Fee',
# 		detail: '%@ locations',
# 		detail_action: 'count_merchants'
# 	}
# 	payment_date: {
# 		recurring_type: 'monthly',
# 		process_day: 5,
# 		weekday: 'monday',
# 		notify_day: 2,
# 		charge_type: 'ach',
# 		charge_id: nil
# 	}
# 	amount: {
# 		cents: 10000,
# 		ccy: "USD",
# 		type: 'variable_merchant'
# 	}
# }

# --------------------------------------------------------------------

# Basic Merchant
# 	fixed monthly subscription fees , one license

# id: '81324681-1241-12414',
# status: 'live',
# partner_id: 3264,
# partner_type: 'Merchant',
# live_date: '10/01/2016',
# end_date: '10/01/2017',
# origin: 'subscription',
# response: {
# 	line_item: {
# 		name: 'Subscription Fee',
# 		detail: 'single locations'
# 	}
# 	payment_date: {
# 		recurring_type: 'monthly',
# 		process_day: 5,
# 		weekday: 'monday',
# 		notify_day: 5,
# 		charge_type: 'Card',
# 		charge_id: 8574 # card.id
# 	}
# 	amount: {
# 		cents: 3000,
# 		ccy: "USD",
# 		type: 'single'
# 	}
# }

# --------------------------------------------------------------------


# rg model License status partner_type partner_id:integer live_date:date
# end_date:date auto_renew:boolean origin line_items:json payment:json amount:json note:text



# id: '238ry1f-23fg12-12312',
# status: 'live',
# partner_id: 56,
# partner_type: 'Affiliate',
# live_date: '10/01/2016',
# end_date: '10/01/2017',
# origin: 'subscription',
# name: 'Subscription Fee',
# detail: '%@ locations',
# detail_action: 'count_merchants'
# amount: 4000,
# ccy: "USD",
# units: nil,
# amount_action: 'variable_merchant'
# recurring_type: 'monthly',
# weekday: 'monday',
# process_day: 5,
# process_month: nil,
# notify_day: 2,
# charge_type: 'Card',
# charge_id: 234 # card.id


# id: '9234fg23-23yf9g3-2hg3f71',
# status: 'live',
# partner_id: 31,
# partner_type: 'Affiliate',
# live_date: '2/01/2016',
# end_date: '2/01/2017',
# auto_renew: false,
# origin: 'subscription',
# name: 'Subscription Fee',
# detail: '100 golf courses - tier 2',
# detail_action: nil,
# amount: 2500000,
# percent: nil,
# amount_action: 'multiple',
# units: 100,
# ccy: "USD",
# recurring_type: 'annual',
# weekday: nil,
# process_month: 2,
# process_day: 1,
# notify_day: nil,
# charge_type: 'check',
# charge_id: nil

      # t.string :partner_type
      # t.integer :partner_id
      # t.date :live_at
      # t.date :expires_at
      # t.string :origin
      # t.string :name
      # t.string :detail
      # t.string :detail_action
      # t.string :amount_action
      # t.integer :amount
      # t.integer :percent
      # t.integer :units
      # t.string :ccy
      # t.string :recurring_type
      # t.string :weekday
      # t.integer :process_month
      # t.integer :process_day
      # t.integer :notify_day
      # t.string :charge_type
      # t.integer :charge_id
      # t.text :note

