class OpsClover

	attr_reader :status, :mid, :key, :clienjt, :merchant, :signup

	def initialize args={}
		if args[:mid].blank? || args[:mid].to_s.length < 5
			@mid = nil
		else
			@mid = args[:mid]
		end
		if args[:application_key].blank?
			@client_key = nil
		else
			@client_key = args[:application_key]
		end
		set_status
	end

	def set_status
		get_client
		get_merchant
		get_signup
		@status = if @client.nil? && @merchant.nil? && @signup.nil?
			@mid.nil? ? :blank : :new
		elsif @client.nil? && @merchant.nil?
			:requested
		else
			mode = @merchant.mode
			if mode == 'live' && @client.nil?
				:live_init
			elsif mode == 'live'
				:live
			elsif @client.nil?
				:paused_init
			else
				:paused
			end
		end
	end


#   -------------


	def get_client
		@client = Client.find_by(application_key: @client_key) if @client_key
	end

	def get_merchant
		@merchant = Merchant.find_by(pos_merchant_id: @mid) if @mid
	end

	def get_signup
		@signup = MerchantSignup.get_clover_signup @mid
	end



end