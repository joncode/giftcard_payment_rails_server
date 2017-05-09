class Booking < ActiveRecord::Base
	# include AuditTrail
	include MoneyHelper

	auto_strip_attributes :name, :email, :phone, :note, :origin, :price_desc


#   -------------

	belongs_to :book

	attr_accessor :time1, :time2

#   -------------

    before_save :set_unique_hex_id, on: :create
    before_save :set_status

#   -------------

	# {"id"=>5, "active"=>true, "hex_id"=>"bk_3dbdc6a9", "name"=>"Kyle Hadley", "email"=>"klyemar@gmail.com",
	# "phone"=>"3602244244", "guests"=>8, "dates"=>nil, "payments"=>nil, "book_id"=>1, "price_unit"=>12000,
	# "note"=>"Test", "created_at"=>Wed, 03 May 2017 16:38:14 UTC +00:00,
	# "updated_at"=>Wed, 03 May 2017 16:38:14 UTC +00:00, "link_id"=>nil,
	# "status"=>"request_date", "origin"=>nil, "date1"=>Sun, 05 Mar 2017 00:00:00 UTC +00:00,
	# "date2"=>Fri, 05 May 2017 00:00:00 UTC +00:00, "event_at"=>nil, "price_desc"=>nil}

	def serialize
		h = self.serializable_hash only: [ :id, :active, :hex_id, :name, :email, :phone,
			 :guests, :book_id, :price_unit, :ccy, :price_desc, :status, :note, :created_at, :origin ]
		h[:book] = self.book ? self.book.list_serialize : nil
		if self.event_at.present?
			h[:event_at] = self.event_at
		else
			h[:date1] = self.date1
			h[:date2] = self.date2
		end
		h
	end

#   -------------

    def time1
		s = self.date1
		if s.respond_to?(:to_formatted_s)
			x = s.to_formatted_s(:only_time)
			x.gsub!(':00','')
			x.strip
		else
			s
		end
    end

    def time2
		s = self.date2
		if s.respond_to?(:to_formatted_s)
			x = s.to_formatted_s(:only_time)
			x.gsub!(':00','')
			x.strip
		else
			s
		end
    end


#   -------------

	def date1_to_s
		s = self.date1
		if s.respond_to?(:to_formatted_s)
			s.to_formatted_s(:numeric_date_time)
		else
			s
		end
	end

	def date2_to_s
		s = self.date2
		if s.respond_to?(:to_formatted_s)
			s.to_formatted_s(:numeric_date_time)
		else
			s
		end
	end

	def event_at_to_s
		s = self.event_at
		if s.respond_to?(:to_formatted_s)
			s.to_formatted_s(:numeric_date_time)
		else
			s
		end
	end

	def accept_booking(stripe_id, stripe_user_id)
		self.status = next_status
		self.stripe_id = stripe_id
		self.stripe_user_id = stripe_user_id
		save
	end

	def accept_date(num=nil)
		if num == 1
			self.event_at = self.date1
			self.status = 'date_accepted'
		elsif num == 2
			self.event_at = self.date2
			self.status = 'date_accepted'
		else
			errors.add(:date_accepted, "is not a valid acceptance date")
			return false
		end
		save
	end

	def next_status
		case self.status
		when 'no_date'
			'request_date'
		when 'request_date'
			'accept_date'
		when 'date_accepted'
			'payment_request'
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


	def book_name
		b = self.book
		if b.respond_to?(:name)
			b.name
		end
	end

	def merchant
		if b = self.book
			b.merchant
		else
			nil
		end
	end

	def merchant_name
		b = self.merchant
		if b.respond_to?(:name)
			b.name
		end
	end

#   -------------

    def self.status_payment
    	[ :unpaid, :customer_charged, :merchant_paid, :customer_refunded ]
    end

    def self.status_date
    	[ :no_date, :request_date, :date_accepted, :complete ]
    end

#   -------------



private

	def set_status
		if self.date1.respond_to?(:to_formatted_s) || self.date2.respond_to?(:to_formatted_s)
			if self.status.nil?
				self.status == 'request_date'
			end
		end
	end

    def set_unique_hex_id
    	if self.hex_id.blank?
	        self.hex_id = UniqueIdMaker.eight_digit_hex(Booking, :hex_id, 'bk_')
	    end
    end

end