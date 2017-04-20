class Booking < ActiveRecord::Base
	include AuditTrail
	include MoneyHelper

	auto_strip_attributes :name, :email, :phone, :note

#   -------------


    before_save :set_unique_hex_id, on: :create
    before_save :set_default_dates, on: :create
    before_save :set_default_payment, on: :create

#   -------------

	belongs_to :book

#   -------------

    def self.status_payment
    	[ :unpaid, :customer_charged, :merchant_paid, :customer_refunded ]
    end

    def self.status_date
    	[ :no_date, :request_date, :merchant_accept_date, :customer_accept_date, :complete ]
    end

#   -------------

	def dates option=nil
		get_audit_trail(super(),option)
	end

	def dates= hsh
		super set_audit_trail(self.dates, hsh)
	end

	def payments option=nil
		get_audit_trail(super(),option)
	end

	def payments= hsh
		super set_audit_trail(self.payments, hsh)
	end

	def default_date
		{
			origin: :system,
			status: :no_date,
		 	next: :request_date
		}
	end

	def default_payment
		{
			status: :unpaid,
			next: :charge_customer
		}
	end


private

	def set_default_dates
		if self.dates.blank?
			self.dates = default_date
		end
	end

	def set_default_payment
		if self.payments.blank?
			self.payments = default_payment
		end
	end

    def set_unique_hex_id
    	if self.hex_id.blank?
	        self.hex_id = UniqueIdMaker.eight_digit_hex(Booking, :hex_id, 'bk_')
	    end
    end

end