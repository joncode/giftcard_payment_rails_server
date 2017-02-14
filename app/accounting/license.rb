class License < ActiveRecord::Base
	extend LicenseMaker
	# 	might be based on live date of the contract, might be based on live date of the locations

	# note -  text field to dump the results of each successful register request

	TODAY = DateTime.now.utc.to_date

	# ENUM :status  'live', 'expired', 'cancel', 'inactive'
	# ENUM :recurring_type 'monthly', 'annual'
	# ENUM :origin  'subscription', 'promo'
	# ENUM :amount_action  'single', 'multiple' , 'variable_merchant', 'variable_redemption'
	# ENUM :charge_type 'card', 'ach', 'wire', 'check'


#   -------------

	validates_inclusion_of :notify_day, :in => 1..30, allow_blank: true, message: 'can either be blank or 1 - 30'
	validates_presence_of :partner_type, :partner_id, :origin, :amount_action,
		:charge_type, :status, :recurring_type

#   -------------

	before_create :set_expires_at
	before_create :set_ccy
	before_create :set_process_dates

#   -------------

	attr_accessor :over_type, :tab

#   -------------

	has_many :registers
	belongs_to :partner, polymorphic: true

#   -------------

	def self.get_live
		where(status: 'live')
	end


	def self.statuses
		['pending', 'live', 'expired', 'cancel', 'stop']
	end

	def self.charge_types
		['card', 'ach', 'wire', 'check']
	end

#   -------------

	def count_merchants
		Merchant.count_for(partner)
	end

	def count_redemptions
		Redemption.count_promo_redemptions_for(partner, start_date, end_date)
	end

	def total_promo_redemptions
		Redemption.total_promo_redemptions_for(partner, start_date, end_date)
	end

#   -------------

	def percentage
		self.percent / 100
	end

	def charge_amount
		return @charge_amount if @charge_amount
		@charge_amount = case self.amount_action
		when 'variable_merchant'
			(count_merchants * self.amount)
		when 'variable_redemption'
			(total_promo_redemptions * self.percentage).to_i  # round up / down ?
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

	def make_monthly_register_today?
		last_register = Register.last_for_license(self)
		if last_register.nil?
			return true
		elsif TODAY.month == last_register.created_at.month
			return false
		elsif (TODAY - 1.month).month == last_register.created_at.month
			if self.live_at.day <= TODAY.day
					# license should have register already , so make one
					# so license is Jan 4 , and date is Feb 7
				return true
			elsif (TODAY == TODAY.end_of_month) && (self.live_at.day >= TODAY.end_of_month.day)
					# charge is on the last day of current month - Jan 31 gets sent on Feb 28
				return true
			else
					# not time to make the register
					# license is Jan 12 and the date is feb 7
				return false
			end
		else
			msg = "REGISTERS ARE OVER A MONTH OLD FAIL #{self.id}"
			puts msg.inspect
			OpsTwilio.text_devs msg: msg
			return false
		end
	end

	def make_annual_register_today?
		last_register = Register.last_for_license(self)
		if last_register.nil?
			return true
		elsif (TODAY.month == self.live_at.month && TODAY.day == self.live_at.day)
			return true
		else
			return false
		end
	end

	def make_register_today?
		case self.recurring_type
		when 'monthly'
			make_monthly_register_today?
		when 'annual'
			make_annual_register_today?
		else
			return false
		end
	end

private

	def set_expires_at
		if self.live_at
			self.expires_at = self.live_at + 1.year
		elsif self.partner.respond_to?(:live_at)
			self.live_at = self.partner.live_at
			self.expires_at = self.live_at + 1.year
		end
	end

	def set_ccy
		if self.ccy.nil? && self.partner
			self.ccy = self.partner.ccy
		end
	end

	def set_process_dates
		if self.recurring_type == 'annual'
			self.process_month = self.live_at.month
			self.process_day = self.live_at.day
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

