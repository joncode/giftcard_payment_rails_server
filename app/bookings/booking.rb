class Booking < ActiveRecord::Base

	HEX_ID_PREFIX = 'bk_'

	include HexIdMethods
	include BookingLifecycle
	include BookingChargeCard
	include MoneyHelper

	auto_strip_attributes :name, :email, :phone, :note, :origin, :price_name

	EXPIRES_INTERVAL = 24

#   -------------

	belongs_to :book

	delegate :merchant, :tax_tip_included, :tax_rate, :tax_rate_display, :tip_rate,
		:tip_rate_display, :tax_name, :tip_name, :ccy, :min_ppl, :max_ppl, :tax_amount_display, :tip_amount_display,
		 to: :book
	delegate :name, prefix: :book, to: :book, allow_nil: true

	delegate :name, prefix: :merchant, to: :merchant, allow_nil: true
	delegate :timezone, to: :merchant, allow_nil: true

	attr_writer :time1, :time2
	attr_accessor :price_id

#   -------------

	validates_presence_of :book, :price_unit, :guests
	# validates_with BookingDateValidator

#   -------------

    before_save :set_status
    before_save :set_expires_at

#   -------------  CLASS API SURFACE


    def self.status_payment
    	[ :unpaid, :customer_charged, :payment_request, :merchant_paid, :customer_refunded ]
    end

    def self.status_date
    	[ :no_date, :request_date, :payment_request, :date_accepted, :complete, :expired ]
    end

    def self.reminders
    	where(active: true).where.not(event_at: nil, status: 'payment_received').find_each do |booking|
    		dt = DateTime.now.utc
    		[7,1].each do |d|

    			if booking.event_at < (d + 1).days.from_now && booking.event_at > d.days.from_now

    				puts "BookingLifecycle.reminder (11) - reminder for booking #{booking.id}"
    				if booking.merchant && booking.merchant.active_live?
    					booking.send_reminder(d)
    				else
    					puts "500 Internal - booking #{booking.id} Reminder at inactive merchant"
    				end
    			end
    		end
    	end
    end


#   -------------


	def expires_interval
		EXPIRES_INTERVAL
	end

	def customer_link
		CLEAR_CACHE + "/bookings/" + self.paper_id
	end

	def admin_link
		PUBLIC_URL_AT + "/bookings/" + self.paper_id
	end

	def to_text
		"#{self.name} has booked the #{self.book_name} top100 experience. Status has changed to '#{self.status.titleize}'. Booking ID = #{self.paper_id}"
	end

	def serialize
		h = self.serializable_hash only: [ :id, :active, :hex_id, :name, :email, :phone, :expires_at,
			 :guests, :book_id, :price_unit, :ccy, :price_name, :status, :note, :created_at, :origin,
			 :event_at, :date1, :date2 ]
		h[:paper_id] = self.paper_id
		h[:expires_interval] = EXPIRES_INTERVAL
 		h[:book] = self.book ? self.book.list_serialize : nil
 		h[:price] = price_subtotal
		h[:price_total] = price_total
		h[:tax_amount] = tax_amount_display(price_subtotal)
		h[:tip_amount] = tip_amount_display(price_subtotal)
		h.stringify_keys
	end

#   -------------

	def price_id= price_id
		puts "IN PRICE ID setter"
		@price_id = price_id
    	return "Book Not Found" unless book
    	price_hsh = book.choose_price(price_id)
    	if price_hsh.blank?
	    	errors.add(:price, "#{price_id} is not found on booking")
	    else
	    	self.price_unit = price_hsh[:price]
	    	self.price_name = price_hsh[:title]
	    end
    	price_hsh
	end

	def price_subtotal
		if guests.to_i > 0
			self.price_unit.to_i * guests.to_i
		else
			self.price_unit.to_i
		end
	end

	def price_total(price_cents=price_subtotal)
		book.price_total(price_cents)
	end
	alias_method :amount, :price_total

	def expired?
		bool = (self.expires_at && self.expires_at < DateTime.now.utc)
		update_column(:status, 'expired') if bool
		return bool
	end

#   -------------

	def resubmit
		# delete expires_at and send alerts to concierge for confirm booking
		self.status = 'resubmit_date'
		self.event_at = nil
		self.expires_at = nil
		unless self.valid?
			self.date1 = nil
			self.date2 = nil
		end
		if save
			customer_resubmits_date_request
			true
		else
			false
		end
	end

#   -------------


    def time1
    	TimeGem.time_from_timestamp(self.date1)
    end

    def time2
    	TimeGem.time_from_timestamp(self.date2)
    end

	def event_at
		TimeGem.set_in_timezone(super, timezone)
	end

	def date1
		TimeGem.set_in_timezone(super, timezone)
	end

	def date2
		TimeGem.set_in_timezone(super, timezone)
	end

	def date1_to_s
		TimeGem.timestamp_to_s(self.date1)
	end

	def date2_to_s
		TimeGem.timestamp_to_s(self.date2)
	end

	def event_at_to_s
		TimeGem.timestamp_to_s(self.event_at)
	end

#   -------------

	def accept_booking(stripe_id, stripe_user_id)
		self.stripe_id = stripe_id
		if save
			o = tokenize_card
			if o.success?
				o.charge_token
				if o.success?
					update(status: 'payment_received', stripe_user_id: o.customer_id)
				else
					errors.add(:charge, "#{o.error_key} #{o.error_message}")
				end
			else
				errors.add(:card_token, "#{o.error_key} #{o.error_message}")
				false
			end
		else
			false
		end
	end

	def accept_date(num=nil)
		if num == 1
			self.event_at = self.read_attribute(:date1)
			self.status = 'date_accepted'
		elsif num == 2
			self.event_at = self.read_attribute(:date2)
			self.status = 'date_accepted'
		else
			errors.add(:date_accepted, "is not a valid acceptance date")
			return false
		end
		if save
			send_purchase_link_to_customer
			true
		else
			false
		end
	end

	def next_status
		case self.status
		when 'no_date'
			'request_date'
		when 'request_date'
			'accept_date'
		when 'resubmit_date'
			'accept_date'
		when 'accept_date'
			'date_accepted'
		when 'date_accepted'
			'payment_request'
		when 'payment_request'
			'payment_received'
		when 'payment_received'
			'complete'
		else
			self.status
		end
	end

	def status
		s = super
		if self.persisted? && s == 'no_date' && (self.date1.present? || self.date2.present?)
			self.update_column(:status, 'request_date')
			return 'request_date'
		end
		s
	end


#   -------------


private


	def set_expires_at
		if self.expires_at.nil? && self.event_at.present?
			self.expires_at = DateTime.now.utc + EXPIRES_INTERVAL.hours
		end
	end

	def set_status
		if self.date1.respond_to?(:to_formatted_s) || self.date2.respond_to?(:to_formatted_s)
			if self.status.blank?
				self.status.to_s == 'request_date'
			end
		end
	end


end


