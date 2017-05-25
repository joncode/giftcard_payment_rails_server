class VerifyGift

	attr_reader :data, :err, :msg, :h

	def initialize prms
		puts "VerifyGift " + prms.inspect
		@success = 0
		@h = prms
	end

	def verify
		num = rand(3)
		if num == 0
			@success = 1
			@data = data: "Gift verified"
		elsif num == 1
			@success = 0
			@err = "SMS_ONE_TIME_VEINVALID_INPUTRIFY_REQUIRED"
			@msg = 'You must verify your mobile phone number'
		else
			@success = 0
			@err = "SMS_ONE_TIME_VERIFY_REQUIRED"
		    @msg = 'You must one time verify your mobile phone number'
		end
	end

	def success?
		@success == 1
	end

	def response
		h = { status: @success }
		h[:data] = @data if @data
		h[:err] = @err if @err
		h[:msg] = @msg if @msg
		h
	end


end