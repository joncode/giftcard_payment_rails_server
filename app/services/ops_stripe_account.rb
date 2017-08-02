require 'stripe'

class OpsStripeAccount
	include MoneyHelper
	include OpsStripeHelper

	attr_reader :ccy, :country, :company, :acct_id, :legal
	attr_accessor :acct_id, :error_code, :error_message, :error

	def initialize company, legal=nil
		Stripe.api_key = STRIPE_SECRET
		Stripe.api_version = "2017-06-05"
		@company = company
		@legal = legal || company.legal
		@ccy = company.ccy || raise
		@country = company.country
		@acct_id = legal.stripe_account_id
		if @acct_id
			account
		end
	end

	def self.init legal
		new(legal.company, legal)
	end

	def save_account
		@account.save
	rescue => e
		puts e.inspect
		process_error(e)
	end

	def success?
		@success
	end

#	-------------

	def add_bank
		bank_account = @company.bank
		return "NO BANK" if bank_account.blank?
		return "No Data" if @account.blank? && @acct_id.blank?

		if @account.blank?
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
	    	if Rails.env.production?
		    	@account.legal_entity.personal_id_number = legal.personal_id
		    else
		    	@account.legal_entity.personal_id_number = '000000000'
		    end
	    end

	    if Rails.env.production?
	    	@account.legal_entity.business_tax_id = legal.business_tax_id
	    else
	    	@account.legal_entity.business_tax_id = '000000000'
	    end
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
		return nil unless @account.present?
		@account.verification
	end

	def fields_needed
		verify.try(:fields_needed) || []
	end

	def verified?
		return nil if fields_needed.nil?
		fields_needed.length == 0 || fields_needed == ["legal_entity.verification.document"]
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
			type: 'custom',
			decline_charge_on: { 'avs_failure' => true, 'cvc_failure' => true },
			metadata: { 'company_id' => c.id}
		})
		if @legal
			@legal.stripe_account_id = @account.id
			@legal.update_column(:stripe_account_id, @account.id) if @legal.persisted?
			add_tos
			add_entity
			save_account
		end
		@acct_id = @account.id
		@account
	end

end






































