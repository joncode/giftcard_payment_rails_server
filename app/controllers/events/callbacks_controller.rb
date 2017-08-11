class Events::CallbacksController < MetalCorsController
	include MtSmsRedeem

	after_filter :set_content_type, only: :receive_sms

	def set_content_type
		self.content_type = "text/plain; charset=utf-8"
	end

	def epson_status
		puts "EPSON RECEIVED ^^^^^  STATUS  ^^^^^ #{params.inspect}"
		@client = ClientUrlMatcher.get_app_key(params['ID'])
		if @client
			partner = @client.partner
			puts "Partner - #{partner.inspect}"
		else
			# do nothing until error state handled
		end
		head :ok
	end

	def epson_check
		puts "EPSON RECEIVED !!!!!!!! CHECK !!!!!!!! #{params.inspect}"
		@client = Client.find_by(application_key: params['ID'])
		if @client
			partner = @client.partner
			puts "Partner - #{partner.inspect}"
				# find the correct redemptionthe
				# get last pending epson redemption at location
			@redemption = Redemption.get_epson_printable_redemption(partner)
		else
			# do nothing until error state handled
		end

		if @redemption
				# format to XML
				# call :to_epson_xml on redemption
				# send the XML to printer for printing
			render xml: @redemption.to_epson_xml
		else
			head :ok
		end
	end

			# # receive confirmation of the printing
			# put up API to receive this message
			# # update and redeem the gift
			# call Redeem.apply_and_complete with this response

	def epson_data
		puts "EPSON RECEIVED ----------------------- DATA ------------------ #{params.inspect}"
		@client = Client.find_by(application_key: params['ID'])
		if @client
			partner = @client.partner
			puts "Partner - #{partner.inspect}"
		else
			# do nothing until
		end
		head :ok
	end


	def receive_sms
		msg = params['Body']
		from_number = params['From']

		# msg = ReceivedMessage.create(params)

		dispatch_message(from_number, params, msg, from_number)

		@app_response = "You've reached ItsOnMe!  One of our people will be texting you shortly.  Thank you, we're here to help :)"
		respond
		# render text: '<?xml version="1.0" encoding="UTF-8" ?><Response></Response>'
	end

	def zappernotify
		ref = params['Reference']

		if ref
			r = Redemption.find_by(hex_id: ref)
			if r.present?
				if r.status == 'done'
					success({ ref: ref, status: r.status })
				else
					puts "found redemption #{r.id}"
					rc = Redeem.apply_and_complete(redemption: r, callback_params: params)
				   	if rc['success']
						success({ ref: ref, status: rc['redemption'].status  })
					else
						fail({ ref: ref, status: r.status  })
					end
				end
			else
				puts "500 Internal - BUG ON ZAPPER ASYNC #{params.inspect}"
				fail({ ref: ref, status: 'failed'  })
			end
		end
		respond
	end

# -----------   Twilio Service Methods

	def dispatch_message from, req, msg, from_number
		# if code = ReceivedMessage.merchant_redemption(msg)
		# 	redemption_msg from, code
		# elsif msg.downcase == 'support'
		# 	basic_support from
		# elsif ["+12152000475","+17029727139"].include?(from)
		# 	flip_phones from, msg
		# end
		Alert.perform("SMS_MESSAGE_RECEIVED_SYS", req)
	end

	def redemption_msg from, code
		mt_user = get_mt_user_with_number from
		if mt_user
			gift = find_gift_if_mt_user_has_notified_gifts(mt_user, code)
			if gift
				msg ="Gift #{code} is #{gift.value_s}"
			else
				msg ="No Gift was found for code = #{code}"
			end
		else
			msg ="No User was found for #{from}"
		end
		OpsTwilio.text to: from, msg: msg
	end

	def basic_support from
		mt_user = get_mt_user_with_number from
		if mt_user
			msg = "Text redemption code to see value of gift"
		else
			msg =  "This is ItsOnMe Support , how may we assist you?"
		end
		OpsTwilio.text to: from, msg: msg
	end

	def flip_phones from_number, msg
		if from_number == "+17029727139"
			to_number = "+12152000475"
		else
			to_number = "+17029727139"
		end
		OpsTwilio.text to: to_number, msg: msg
	end

private

	def zapper_params
		params.require(:data).permit("Reference", "PaymentStatusId", "PSPData", "Amount", "ZapperId", "UpdatedDate")
	end
end


# zapper_request = r.request
#          zapper_request['redemption_id'] = r.hex_id
#          zapper_obj = OpsZapper.new(zapper_request)
#          zapper_obj.apply_callback_response(params)
	# zapper_obj = rc['pos_obj']
#    if zapper_obj.success?
#     if zapper_obj.code == 201
#         gift.partial_redeem(zapper_obj, gift.merchant.id, r)
#     elsif zapper_obj.code == 200 || zapper_obj.code == 206
#         gift.redeem_gift(nil, gift.merchant.id, :zapper, zapper_obj, r)
#     end

# {"ToCountry"=>"US",
#  "ToState"=>"CA",
#  "SmsMessageSid"=>"SMf936c25f0b7fc1b5a569ed29fe4c3375",
#  "NumMedia"=>"0",
#  "ToCity"=>"LOS ANGELES",
#  "FromZip"=>"",
#  "SmsSid"=>"SMf936c25f0b7fc1b5a569ed29fe4c3375",
#  "FromState"=>"NV",
#  "SmsStatus"=>"received",
#  "FromCity"=>"",
#  "Body"=>"Andtoid rocking ",
#  "FromCountry"=>"US",
#  "To"=>"+13107364884",
#  "ToZip"=>"90240",
#  "NumSegments"=>"1",
#  "MessageSid"=>"SMf936c25f0b7fc1b5a569ed29fe4c3375",
#  "AccountSid"=>"ACa3fd35ae074a400b0af789bf7c71b0c4",
#  "From"=>"+17029727139",
#  "ApiVersion"=>"2010-04-01"}
