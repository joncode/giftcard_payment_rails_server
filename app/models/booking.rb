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

	def accept_date(num=nil)
		if num == 1
			self.event_at = self.date1
			self.status = 'date_accepted'
		elsif num == 2
			self.event_at = self.date2
			self.status = 'date_accepted'
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