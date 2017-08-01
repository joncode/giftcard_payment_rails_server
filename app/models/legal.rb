class Legal < ActiveRecord::Base

#   -------------

    auto_strip_attributes :first_name, :business_tax_id, :last_name,
    	:date_of_birth, :merchant_ein, :personal_id

#   -------------

	validates_presence_of :business_tax_id, :company_id, :company_type
	validates_presence_of :date_of_birth, :first_name, :last_name, :personal_id, if: :non_us?
	validates_uniqueness_of :company_id, scope: :company_type

#   -------------

	before_save { |legal| legal.first_name = first_name.titleize if first_name }
	before_save { |legal| legal.last_name  = NameCase(last_name) if last_name  }

#   -------------

	attr_reader :account

	belongs_to :company, polymorphic: true
	delegate :bank, to: :company
	delegate :name, prefix: :company, to: :company

#   -------------

	def personal_id
		super || self.business_tax_id
	end

	def first_name
		super || company_name
	end

	def last_name
		super || company_name
	end

	def account
		@account ||= OpsStripeAccount.init(self)
	end

	def verified?
		account.verified?
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


private

	def non_us?
		self.company.ccy != 'USD' if self.company
	end


end