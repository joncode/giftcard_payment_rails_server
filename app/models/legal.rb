class Legal < ActiveRecord::Base

#   -------------

    auto_strip_attributes :first_name, :business_tax_id, :last_name,
    	:date_of_birth, :merchant_ein, :personal_id

#   -------------


#   -------------

	validates_presence_of :company_id, :company_type
	validates_presence_of :business_tax_id, message: "Tax ID can't be blank"
	validates_presence_of :date_of_birth, :first_name, :last_name, if: :non_us?
	validates_presence_of :personal_id, if: :non_us?, message: "Tax ID Number can't be blank"
	validates_uniqueness_of :company_id, scope: :company_type
	validates_inclusion_of :tos, :in => [true], message: " - You must agree to the Terms of Service"

#   -------------

	before_save { |legal| legal.first_name = first_name.titleize if first_name }
	before_save { |legal| legal.last_name  = NameCase(last_name) if last_name  }
	# before_save :send_to_stripe

#   -------------

	belongs_to :company, polymorphic: true
	delegate :bank, to: :company
	delegate :name, prefix: :company, to: :company
	delegate :country, :ccy, to: :company


#   -------------

	def send_to_stripe
		return true if verified?
		return true unless non_us?
		account.account
		self.stripe_account_id = account.acct_id if self.stripe_account_id.blank?

		if bank.nil?
			errors.add(:bank, "Please add your bank account on the sidebar")
			return false
		end

		if stripe_verify_check?
			return true
		else
			if stripe_errors.include?("external_account")
				if bank.nil?
					errors.add(:bank, "- Please add your bank account on the sidebar")
					return false
				else
					account.add_bank
					if account.error_message
						errors.add(:stripe, account.error_message)
						puts account.inspect
						return false
					end
				end
			end
			if stripe_verify_check?
				return true
			else
				errors.add(:verification, stripe_errors.join(' - '))
				puts account.inspect
				return false
			end
		end
	end

	def personal_id
		super || self.business_tax_id
	end

	def business_tax_id
		super
	end

	def first_name
		super
	end

	def last_name
		super
	end

	def account
		@account = OpsStripeAccount.init(self)
	end

	def verified?
		self.verified
	end

	def stripe_verify_check?
		bool = account.verified? || false
		self.verified = bool
		bool
	end

	def stripe_errors
		account.fields_needed
	end

	def dob_obj
		TimeGem.string_stamp_to_datetime(self.date_of_birth)
	end

#   -------------

	def self.tos= val
		# do nothing
	end

	def self.tos_accept_at= val
		# do nothing
	end

	def self.tos_ip= val
		# do nothing
	end


	def non_us?
		country != 'US'
	end

private


end