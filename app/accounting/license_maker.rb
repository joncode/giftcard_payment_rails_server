module LicenseMaker

	def monthly_basic(partner = nil)
		l = new
		l.over_type = 'Monthly Basic'
		l.status = 'live'
		l.origin = 'subscription'
		l.name = 'Monthly Single Subscription'
		l.detail = 'single location'
		l.detail_action = nil
		l.amount = 3000
		l.percent = nil
		l.amount_action = 'single'
		l.units = 1
		if partner
			l.partner_id = partner.id
			l.partner_type = partner.class.to_s
			l.ccy = partner.ccy
		else
			l.ccy = "USD"
		end
		l.recurring_type = 'monthly'
		l.weekday = 'monday'
		l.process_day = 5
		l.process_month = nil
		l.notify_day = nil
		l
	end

	def annual_basic(partner = nil)
		l = new
		l.over_type = 'Annual Basic'
		l.status = 'live'
		l.origin = 'subscription'
		l.name = 'Annual Single Subscription'
		l.detail = 'single location'
		l.detail_action = nil
		l.amount = 30000
		l.percent = nil
		l.amount_action = 'single'
		l.units = 1
		if partner
			l.partner_id = partner.id
			l.partner_type = partner.class.to_s
			l.ccy = partner.ccy
		else
			l.ccy = "USD"
		end
		l.recurring_type = 'annual'
		l.weekday = nil
		l.process_day = 1
		l.process_month = 2
		l.notify_day = nil
		l
	end

	def monthly_variable(partner = nil)
		l = new
		l.over_type = 'Monthly Variable'
		l.status = 'live'
		l.origin = 'subscription'
		l.name = 'Monthly Multiple Subscription'
		l.detail = 'locations'
		l.detail_action = 'count_merchants'
		l.amount = 4000
		l.percent = nil
		l.amount_action = 'variable_merchant'
		l.units = nil
		if partner
			l.partner_id = partner.id
			l.partner_type = partner.class.to_s
			l.ccy = partner.ccy
		else
			l.ccy = "USD"
		end
		l.recurring_type = 'monthly'
		l.weekday = 'monday'
		l.process_month = nil
		l.process_day = 5
		l.notify_day = nil
		l
	end

	def annual_fill_up(partner = nil)
		l = new
		l.over_type = 'Annual Subscription Fill Up'
		l.status = 'live'
		l.origin = 'subscription'
		l.name = 'Annual Subscription Package'
		l.detail = 'locations'
		l.detail_action = nil
		l.amount = 2500000
		l.percent = nil
		l.amount_action = 'multiple'
		l.units = 100
		if partner
			l.partner_id = partner.id
			l.partner_type = partner.class.to_s
			l.ccy = partner.ccy
		else
			l.ccy = "USD"
		end
		l.recurring_type = 'annual'
		l.weekday = nil
		l.process_month = 2
		l.process_day = 1
		l.notify_day = nil
		l
	end

	def monthly_promo_gift(partner = nil)
		l = new
		l.over_type = 'Monthly Promo Gift'
		l.status = 'live'
		l.origin = 'promo'
		l.name = 'Monthly Promotions Package'
		l.detail = 'promotional gift redemptions'
		l.detail_action = 'count_redemptions'
		l.amount = nil
		l.percent = 5
		l.amount_action = 'variable_redemption'
		l.units = nil
		if partner
			l.partner_id = partner.id
			l.partner_type = partner.class.to_s
			l.ccy = partner.ccy
		else
			l.ccy = "USD"
		end
		l.recurring_type = 'monthly'
		l.weekday = 'monday'
		l.process_day = 5
		l.process_month =  nil
		l.notify_day = nil
		l
	end




end

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
# name: 'Promotions Fee',
# detail: '%@ promotional gift redemptions',
# detail_action: 'count_redemptions'
# recurring_type: 'monthly',
# process_day: 5,
# weekday: 'monday',
# notify_day: 2,
# charge_type: 'credit_card',
# charge_id: 234 # card.id
# percentage: 0.05,
# ccy: "USD",
# amount_action: 'variable_redemption'


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
# 		detail: 'single location'
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
