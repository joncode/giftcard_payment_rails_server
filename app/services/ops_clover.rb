 #  {:zip=>"89101", :phone=>"702-555-1212", :website=>"https://www.itson.me", :locale=>"en_US", :state=>"NV", :vat=>false,
 #   :address1=>"123 Mockingbird Lane", :address2=>"Apt 2b", :device_id=>"74e6a379-9a1f-4511-ac6c-96e4b54c10b8", :address3=>"",
 #   :support_email=>"dev@clover.com", :city=>"Las Vegas", :currency=>"USD", :id=>"J4Q1V4P5X0KS0", :time_zone=>"Pacific Standard Time",
 #   :email=>"richard1@rangerllt.com", :support_phone=>"(000) 000-0000",
 #   :name=>"ItsOnMe Test Merchant", :account=>"Account {name=ItsOnMe Test Merchant | richard1@rangerllt.com (DEV), type=com.clover.account}",
 #   :mid=>"RCTST0000008099", :app_key=>"", :serial_number=>"C010UQ61030017", :pos_merchant_id=>"J4Q1V4P5X0KS0", :ccy=>"USD"}



class OpsClover
	include ActionView::Helpers::NumberHelper

	attr_accessor :pos_merchant_id, :key, :app_key, :amount, :ccy, :code
	attr_reader :status, :client, :merchant, :signup, :args, :device_id,
		:merchant_name, :merchant_email, :error, :auth_token

	def initialize args={}
		@error = nil
		@args = args.symbolize_keys
		if @args[:pos_merchant_id].blank? || @args[:pos_merchant_id].to_s.length < 5
			@pos_merchant_id = nil
		else
			@pos_merchant_id = @args[:pos_merchant_id]
		end
		if @args[:app_key].blank?
			@app_key = nil
		else
			@app_key = @args[:app_key]
		end

		if @args[:auth_token].blank?
			@auth_token = nil
		else
			@auth_token = @args[:auth_token]
		end

		# @key = 'g1i12ant_client41314_+mreta12_key-moc1241k=_124)mock_mock' # MOCK of @@app_key

		@key = @app_key
		@device_id = @args[:device_id]
		@merchant_name = @args[:name]
		@merchant_email = @args[:email]
		@amount = @args[:amount] || 0
		@ccy = @args[:ccy]
		@code = @args[:code]
		@base_url = @args[:base_url]

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
		h[:merchant_id] = pos_merchant_id
		h[:stoplight] = stoplight
		h[:support_phone] = TWILIO_QUICK_NUM
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
			make_signup
			make_client
			set_status
		when :blank
			# do nothing
		when :live
			# do nothing
		when :paused
			# do nothing
		when :requested
			make_merchant
			make_client
			set_status
		else
			# do nothing
		end
		meta
	end

	def set_status

		# return @status = [:blank, :new, :requested, :paused, :live].sample

		if @merchant.nil? && @signup.nil?
			x = @pos_merchant_id.blank? ? :blank : :new
		elsif @merchant.nil? && @signup.present?
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
				# How to auto-move the merchant sign up client to the merchant via clover pos_merchant_id
			x = :paused
			if @client.partner.class.to_s == 'MerchantSignup'
				if @merchant && @merchant.pos_merchant_id == @client.partner.pos_merchant_id
					@client.partner = @merchant
					if @client.save && @merchant.mode == 'live'
						x = :live
					else
						puts "OpsClover 126 - CLIENT ERROR - #{@client.errors.full_messages}"
					end
				end
			end
		end
		@status = x
	end


#   -------------


	def make_client
		merchant_obj = @merchant || @signup
		if @client.nil? && merchant_obj
			@client = Client.new_clover_client(merchant_obj)
			if @client.save
				# ready to go
			else
				puts "OpsClover 159 - CLIENT ERROR - #{@client.errors.full_messages}"
				@client = nil unless @client.persisted?
			end
		end
		puts @client.inspect
		@client
	end

	def make_merchant
		if @signup && @signup.persisted?
			get_merchant
			if @merchant.nil?
				@merchant = MerchantClover.make(@signup)
				unless @merchant.persisted?
					# merchant not persisted
					@error = @merchant.errors.full_messages[0]

					@merchant = nil
				end
			end
		end
		puts "\n\n"
		puts @merchant.inspect
		puts "\n\n"
		set_status
		@merchant
	end

	def make_signup
		if @signup.nil? && @merchant_name.present? && @merchant_email.present?
			@signup = MerchantSignup.new_clover @args
			if @signup.save
				make_merchant
			else
				puts "OpsClover 183 - SIGNUP ERROR - #{@signup.errors.full_messages}"
				@signup = nil unless @signup.persisted?
			end
		end
		puts "\n\n"
		puts @signup.inspect
		puts "\n\n"

		@signup
	end


#   -------------


	def get_client
		puts "OpsClover 199 - GET CLIENT for #{@app_key}"
		if !@app_key.blank?
			@client = Client.find_by(application_key: @app_key, active: true)
			if @client.respond_to?(:click)
				puts "OpsClover - 203 CLIENT FOUND #{@client.id}"
				@client.click
			end
		end
	end

	def get_merchant
		puts "OpsClover 210 - GET Merchant for #{@pos_merchant_id}"
		if @pos_merchant_id
			@merchant = Merchant.find_by(pos_merchant_id: @pos_merchant_id, active: true)
		elsif @client && @client.partner_type == "Merchant"
			@merchant = @client.partner
		end
		if @merchant
			@merchant.clover_auth_token = @auth_token
			@merchant
		end
	end

	def get_signup
		puts "OpsClover 219 - GET MerchantSignup for #{@pos_merchant_id}"

		if @pos_merchant_id && @merchant.nil?
			@signup = MerchantSignup.get_clover_signup @pos_merchant_id
		end

	end


end



		# if app_key
		# 	client = Client.include(:partner).find_by(application_key: app_key)
		# 	if client && client.active
		# 		partner = client.partner
		# 		if partner.pos_merchant_id == pos_merchant_id
		# 			# good to go
		# 		else
		# 			# machine has incorrect application key / merchant ID sync
		# 		end
		# 	else
		# 		# client not found with application key
		# 	end
		# else
		# 	m = Merchant.find_by(pos_merchant_id: pos_merchant_id)
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
		# how do we connect the clover machine to the merchant record