require 'stripe'

class OpsStripeAccount
	include MoneyHelper
	include OpsStripeHelper

	attr_reader :ccy, :country, :company, :acct_id, :legal
	attr_accessor :acct_id

	def initialize company, legal=nil
		Stripe.api_key = STRIPE_SECRET
		Stripe.api_version = "2017-06-05"
		@company = company
		@legal = legal
		@ccy = @company.ccy || raise
		@country = company.country
	# where is account_id stored ?
		# @acct_id = "acct_1AHjDxGlvoo2SeX5"
	end

	def save_account
		@account.save
	rescue => e
		puts e.inspect
		process_error(e)
	end

#	-------------

	def add_bank
		bank_account = @company.bank
		return "NO BANK" if bank_account.blank?
		if @account.blank? && @acct_id.blank?
			return "No Data"
		else @account.blank?
			retrieve_account
		end

		if @account
			@ext_acct = @account.external_accounts.create(external_account: {
				object: 'bank_account',
				country: @country,
				currency: @ccy,
				account_number: bank_account.display_account_number(:acct),
				routing_number: bank_account.display_aba(:acct)
			})
		end
	rescue => e
		puts e.inspect
		process_error(e)
	end

	def add_entity legal=@legal, c=@company
		if legal.dob_obj.respond_to?(:day)
			@account.legal_entity.dob.day = legal.dob_obj.day
	    	@account.legal_entity.dob.month = legal.dob_obj.month
	    	@account.legal_entity.dob.year = legal.dob_obj.year
	    end
	    if legal.first_name.present?
	    	@account.legal_entity.first_name = legal.first_name
	    	@account.legal_entity.last_name = legal.last_name
	    	@account.legal_entity.personal_id_number = legal.personal_id
	    end

    	@account.legal_entity.business_tax_id = legal.business_tax_id
    	@account.business_name = c.name
    	@account.business_url = c.website

    	@account.legal_entity.business_name = c.name
    	@account.legal_entity.address.line1 = c.address
    	@account.legal_entity.address.city = c.city_name
    	@account.legal_entity.address.state = c.state
    	@account.legal_entity.address.postal_code = c.zip
    	@account.legal_entity.type = 'company'
    	@account.legal_entity
	end

	def add_tos legal=@legal
		@account.tos_acceptance.date = legal.tos_accept_at.to_i
		@account.tos_acceptance.ip = legal.tos_ip.to_s
		@account.tos_acceptance
	end

	def verify
		return "NO ACCOUNT" unless @account.present?
		@account.verification
	end

#	-------------

	def account
		return @account if @account.present?
		if @acct_id.present?
			retrieve_account
		else
			create_account
		end
	end

	def retrieve_account acct_id=@acct_id
		@account = Stripe::Account.retrieve(acct_id)
	end

	def create_account country=@country, c=@company
		@account = Stripe::Account.create({
			country: country,
			managed: true,
			decline_charge_on: { 'avs_failure' => true, 'cvc_failure' => true },
			metadata: { 'company_id' => c.id}
		})
		if @legal
			add_tos
			add_entity
			save_account
		end
		@acct_id = @account.id
		@account
	end

end