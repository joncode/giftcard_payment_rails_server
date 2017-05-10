require 'stripe'

class OpsStripeAccount

	attr_reader :ccy, :country, :company, :acct_id

	def initialize company
		Stripe.api_key = STRIPE_SECRET
		@company = company
		@ccy = @company.ccy || raise
		@country = { 'USD' => 'US' , "CAD" => 'CA', "GBP" => 'GB'}[@ccy]
	# where is account_id stored ?
		@acct_id = "acct_1AHjDxGlvoo2SeX5"
	end

	def save_account
		@account.save
	end

	def add_entity legal
		@account.legal_entity.dob.day = legal.dob_obj.day
    	@account.legal_entity.dob.month = legal.dob_obj.month
    	@account.legal_entity.dob.year = legal.dob_obj.year
    	@account.legal_entity.first_name = legal.first_name
    	@account.legal_entity.last_name = legal.last_name
    	@account.legal_entity.type = 'company'
    	@account.legal_entity
	end

	def add_tos legal
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

	def create_account c=@country
		@account = Stripe::Account.create({ :country => c, :managed => true })
	end

end