class GiftAnalytic < ActiveRecord::Base

	validates_uniqueness_of :date_on

#   -------------

	def self.return_date(datetime)
		return nil if datetime.nil?
		if datetime.hour >= 14
		    return datetime.to_date
		else
		    return (datetime.to_date - 1.day)
		end
	end

	def self.calculate_created_at(gift)
		c_date = return_date(gift.created_at)
		c_ga = GiftAnalytic.find_or_initialize_by(date_on: c_date)
		c_ga.get_numbers_created(gift)
		c_ga.save
		return c_ga
	end

	def self.calculate_notified_at(gift, c_ga)
		n_date = return_date(gift.notified_at)
		if n_date.present?
			if c_ga && n_date == c_ga.date_on
				n_ga = c_ga
			else
				n_ga = GiftAnalytic.find_or_initialize_by(date_on: n_date)
			end
			n_ga.get_numbers_notified
			n_ga.save
		end
		return n_ga
	end

	def self.calculate_redeemed_at(gift, c_ga, n_ga)
		r_date = return_date(gift.redeemed_at)
		if r_date.present?
			if c_ga && r_date == c_ga.date_on
				r_ga = c_ga
			elsif n_ga && r_date == n_ga.date_on
				r_ga = n_ga
			else
				r_ga = GiftAnalytic.find_or_initialize_by(date_on: r_date)
			end
			r_ga.get_numbers_redeemed(gift)
			r_return = r_ga.save
		end
		return r_ga
	end

	def self.calculate_all(gift)

		c_date = return_date(gift.created_at)
		c_ga = GiftAnalytic.find_or_initialize_by(date_on: c_date)
		c_ga.get_numbers_created(gift)
		c_return = c_ga.save

		n_date = return_date(gift.notified_at)
		if n_date.present?
			if n_date != c_date
				n_ga = GiftAnalytic.find_or_initialize_by(date_on: n_date)
			else
				n_ga = c_ga
			end
			n_ga.get_numbers_notified
			n_return = n_ga.save
		end

		r_date = return_date(gift.redeemed_at)
		if r_date.present?
			if r_date != c_date
				if r_date != n_date
					r_ga = GiftAnalytic.find_or_initialize_by(date_on: r_date)
				else
					r_ga = n_ga
				end
			else
				r_ga = c_ga
			end
			r_ga.get_numbers_redeemed(gift)
			r_return = r_ga.save
		end
		return [c_return,n_return,r_return]
	end

#   -------------

	def get_numbers_redeemed(g)
		self.velocity   += 1
		self.completed  += 1
		case g.status
		when 'redeemed'
			self.redeemed  += 1
		when 'expired'
			self.expired   += 1
		when 'regifted'
			self.cregifted += 1
		else
			# no field for this
		end
	end

	def get_numbers_notified
		self.velocity  += 1
		self.notified  += 1
	end

	def get_numbers_created(g)
		self.velocity += 1
		self.created  += 1
		case g.cat
		when 300
			self.purchase += 1
			self.revenue  += (g.value_f + g.service_f) * 100
			self.profit   += -g.fee * 100
			self.retail_v += g.value_f * 100
		when 307
			self.boomerang += 1
		when 100
			self.admin 	  += 1
		when 200
			self.merchant += 1
		when 150, 250
			self.campaign += 1
		when 101 , 151 , 201 , 251 , 301
			self.regifted += 1
		else
			self.other 	  += 1
		end
	end
end


# t.date       :date
# t.integer    :created, default: 0
# t.integer    :admin, default: 0
# t.integer    :merchant, default: 0
# t.integer    :campaign, default: 0
# t.integer    :purchase, default: 0
# t.integer    :boomerang, default: 0
# t.integer    :other, default: 0
# t.integer    :regifted, default: 0
# t.integer    :notified, default: 0
# t.integer    :redeemed, default: 0
# t.integer    :expired, default: 0
# t.integer    :cregifted, default: 0
# t.integer    :completed, default: 0
# t.integer    :velocity, default: 0
# t.integer    :revenue, default: 0
# t.integer    :profit, default: 0
# t.integer    :retail_v, default: 0# == Schema Information
#
# Table name: gift_analytics
#
#  id         :integer         not null, primary key
#  date_on    :date
#  created    :integer         default(0)
#  admin      :integer         default(0)
#  merchant   :integer         default(0)
#  campaign   :integer         default(0)
#  purchase   :integer         default(0)
#  boomerang  :integer         default(0)
#  other      :integer         default(0)
#  regifted   :integer         default(0)
#  notified   :integer         default(0)
#  redeemed   :integer         default(0)
#  expired    :integer         default(0)
#  cregifted  :integer         default(0)
#  completed  :integer         default(0)
#  velocity   :integer         default(0)
#  revenue    :integer         default(0)
#  profit     :integer         default(0)
#  retail_v   :integer         default(0)
#  created_at :datetime
#  updated_at :datetime
#

