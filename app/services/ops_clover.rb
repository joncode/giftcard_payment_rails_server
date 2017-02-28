class OpsClover
	include ActionView::Helpers::NumberHelper

	attr_accessor :mid, :key, :app_key, :amount, :ccy, :code
	attr_reader :status, :client, :merchant, :signup, :args, :device_id,
		:merchant_hsh, :merchant_name, :merchant_email

	def initialize args={}
		@args = args
		if args[:mid].blank? || args[:mid].to_s.length < 5
			@mid = nil
		else
			@mid = args[:mid]
		end
		if args[:app_key].blank?
			@app_key = nil
		else
			@app_key = args[:app_key]
		end
		# @key = 'g1i12ant_client41314_+mreta12_key-moc1241k=_124)mock_mock' # MOCK of @@app_key

		@merchant_hsh = args[:merchant]

		puts "OpsClover INIT - merchant hsh = #{@merchant_hsh}"

		@key = @app_key
		@device_id = args[:device_id]
		@merchant_name = args[:name]
		@merchant_email = args[:email]
		@amount = args[:amount] || 0
		@ccy = args[:ccy]
		@code = args[:code]

		get_client
		get_merchant
		get_signup
		set_status
	end

	def stoplight
		num = 1
		num = 0 if [:blank, :new].include?(status)
		num = 2 if [:live].include?(status)
		[:stop, :support, :live][num]
	end

	def meta
		h = {}
		if key != @app_key
			h[:application_key] = key
		end
		h[:merchant_id] = mid
		h[:stoplight] = stoplight
		h[:support_phone] = number_to_phone(TWILIO_PHONE_NUMBER, area_code: true)
		h[:support_email] = 'support@itson.me'
		h
	end

#   -------------

	def key
		if @client.respond_to?(:application_key) && @client.application_key
			@key = @client.application_key
		end
		return @key
	end

	def get_redemptions_for_hex_id_or_token unique_id
		if @merchant
			@merchant.get_redemptions_for_hex_id_or_token(unique_id)
		elsif @client
			@client.partner.get_redemptions_for_hex_id_or_token(unique_id)
		else
			[]
		end
	end

#   -------------

	def update_status
		case status
		when :new
			make_requested
			meta
		when :blank
			meta
		when :live
			# do nothing
			meta
		when :paused
			# do nothing
			meta
		when :requested
			# do nothing
			meta
		else
			# do nothing
			meta
		end
	end

	def set_status

		# return @status = [:blank, :new, :requested, :paused, :live].sample

		if @client.nil? && @merchant.nil? && @signup.nil?
			x = @mid.nil? ? :blank : :new
		elsif @client.nil? && @merchant.nil?
			x = :new
		elsif @merchant.nil?
			x = :requested
		elsif @client.nil?
			make_client
			if @client.kind_of?(Client)
				x = :live
			else
				x = :paused
			end
		elsif @merchant == @client.partner && @merchant.mode == 'live'
			x = :live
		else
				# check to see if owned by MerchantSignup - auto-move partner to merchant
				# re-run this method to set status with :mode
				# How to auto-move the merchant sign up client to the merchant via clover mid
			x = :paused
			if @client.partner.class.to_s == 'MerchantSignup'
				if @merchant && @merchant.pos_merchant_id == @client.partner.pos_merchant_id
					@client.partner = @merchant
					if @client.save && @merchant.mode == 'live'
						x = :live
					else
						puts "CLIENT ERROR - #{@client.errors.full_messages}"
					end
				end
			end
		end
		@status = x
	end


#   -------------


	def make_requested
		if status == :new
			# 1. create a @merchant_signup
			make_signup
			make_client

			# 3. :promote the @merchant_signup clients to the merchant with merchant.promote in ADMT
			# 4. set status to :requested
			set_status
		end
		# 5. return the :application_key
		key
	end

	def make_client
		merchant_obj = @merchant || @signup
		if @client.nil? && merchant_obj
			@client = Client.new_clover_client(merchant_obj)
			if @client.save
				# ready to go
			else
				puts "CLIENT ERROR - #{@client.errors.full_messages}"
				@client = nil unless @client.persisted?
			end
		end
		puts @client.inspect
		@client
	end

	def make_signup
		if @signup.nil? && @merchant_name.present? && @merchant_email.present?
			@signup = MerchantSignup.new_clover @args
			if @signup.save
				# 2. make a clover client and connect to the merchant signup
			else
				puts "SIGNUP ERROR - #{@signup.errors.full_messages}"
				@signup = nil unless @signup.persisted?
			end
		end
		puts @signup.inspect
		@signup
	end


#   -------------

	def get_client
		puts "GET CLIENT for #{@app_key}"
		if @app_key
			@client = Client.find_by(application_key: @app_key)
			if @client.respond_to?(:click)
				puts "CLIENT FOUND #{@client.id}"
				@client.click
			end
		end
	end

	def get_merchant
		puts "GET Merchant for #{@mid}"
		if @mid
			@merchant = Merchant.find_by(pos_merchant_id: @mid)
		elsif @client && @client.partner_type == "Merchant"
			@merchant = @client.partner
		end
	end

	def get_signup
		puts "GET MerchantSignup for #{@mid}"

		if @mid && @merchant.nil?
			@signup = MerchantSignup.get_clover_signup @mid
		end

	end


end



		# if app_key
		# 	client = Client.include(:partner).find_by(application_key: app_key)
		# 	if client && client.active
		# 		partner = client.partner
		# 		if partner.pos_merchant_id == mid
		# 			# good to go
		# 		else
		# 			# machine has incorrect application key / merchant ID sync
		# 		end
		# 	else
		# 		# client not found with application key
		# 	end
		# else
		# 	m = Merchant.find_by(pos_merchant_id: mid)
		# 	if m
		# 		client = Client.new_clover_client(m)
		# 		if client.save
		# 			# ready to go
		# 		else
		# 			# failed attempt to make a client
		# 		end
		# 	else
		# 		# merchant not found via clover merchant_id
		# 	end
		# end
		# use information from the clover machine
		# generate a client key for this clover
		# how do we connect the clover machine to the merchant record ?