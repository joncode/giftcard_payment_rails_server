class Positronics

	include ActionView::Helpers::NumberHelper
	require 'rest_client'

	attr_reader :response

	def initialize args
		puts "Positronics args = #{args.inspect}"
		@ticket_number   = args["ticket_num"]
		@ticket_id       = nil
		@gift_card_id    = args["gift_card_id"]
		@pos_merchant_id = args["pos_merchant_id"]
		@value           = args["value"]
		@code 		     = 100
		@extra           = 0
		@applied_value   = @value
		@response        = response_from_code
	end

	def success?
		(200..299).cover?(@code)
	end

	def redeem
		tix = get_tickets_at_location
		tic = get_ticket_from_tix(tix)

		if tic.nil?
			@code = 404
		else
			if tic["closed_at"].nil?
				@ticket_id = tic["id"]
				total      = tic["totals"]["due"].to_i

				if @value < total.to_i
					@code  = 206   # ok , the gift has partially covered the ticket cost
					@extra = total.to_i - @value
				elsif @value > total.to_i
					@code  = 201    # ok , a new gift has been created for the extra gift value
					@extra = @value - total.to_i
					@applied_value = total.to_i
				else
					@code  = 200   # ok , full aceeptance
				end

				resp = post_redeem
				case resp
				when "pos-merchant_id incorrect"
					@code = 509
				when "server_missing"
					@code = 500
				else
					# all good
				end
			else
				@code = 304
			end
		end
		@response = response_from_code
		return @response
	end

private

	def response_from_code
		case @code
		when 100
			r_code = "OPEN"
			r_text = "Gift has not been redeemed yet."
		when 200
			r_code = "PAID"
			r_text = "Gift value matched Ticket value, transaction completed."
		when 201
			r_code = "OVER_PAID"
			r_text = "Gift Value exceeds the ticket value. #{number_to_currency(@extra/100.0)} remain on the gift."
		when 206
			r_code = "APPLIED"
			r_text = "Ticket Value exceeds the gift value. The gift value will be applied in full. #{number_to_currency(@extra/100.0)} remain on the ticket."
		when 304
			r_code = "ERROR"
			r_text = "Ticket Number #{@ticket_num} has already been paid."
		when 404
			r_code = "ERROR"
			r_text = "No Ticket was found for ticket number #{@ticket_num}"
		when 500
			r_code = "ERROR"
			r_text = "Internal Error please contact support@itson.me"
		when 509
			r_code = "ERROR"
			r_text = "Merchant Server Unavailable.  Please try again later."
		else
			r_code = "ERROR"
			r_text = "Server Error.  Please try again later"
		end
		{ "response_code" => r_code, "response_text" => r_text}
	end

	def post_redeem
		payload = {
		  "type" => "gift_card",
		  "amount" => @applied_value,
		  "tip" => 0,
		  "card_info" => {
		    "number" => "#{@gift_card_id}" 		# String, Required gift card number, as a string.
		  }
		}.to_json

		response = RestClient.post(
		    "#{POSITRONICS_API_URL}/locations/#{@pos_merchant_id}/tickets/#{@ticket_id}/payments/",
		    payload,
		    {:content_type => :json, :'Api-Key' => POSITRONICS_API_KEY }
		)
		JSON.parse response
	end

	def get_ticket_from_tix(tix)
		tix.select { |t| t["ticket_number"] == @ticket_num }.first
	end

	def get_tickets_at_location
		response = RestClient.get(
		    "#{POSITRONICS_API_URL}/locations/#{@pos_merchant_id}/tickets",
		    {:content_type => :json, :'Api-Key' => POSITRONICS_API_KEY }
		)
		resp = JSON.parse response
		resp["_embedded"]["tickets"]
	end

	# def redeem_gift_old(value, ticket_num, pos_merchant_id, gift_card_id)
	# 	value = value.to_i
	# 	response = RestClient.get(
	# 	    "#{POSITRONICS_API_URL}/locations/#{pos_merchant_id}/tickets",
	# 	    {:content_type => :json, :'Api-Key' => POSITRONICS_API_KEY }
	# 	)
	# 	resp = JSON.parse response
	# 	tix = resp["_embedded"]["tickets"]
	# 	tic = nil
	# 	tic = tix.select { |t| t["ticket_number"] == ticket_num.to_i }.first
	# 	if value == 0
	# 		error = "Value entered was not a number"
	# 	elsif tic.present?
	# 		if tic["closed_at"].nil?
	# 			total = tic["totals"]["due"].to_i

	# 			if value.to_i < total.to_i
	# 				extra = total.to_i - value.to_i
	# 				text = "Ticket Value exceeds the gift value. The gift value will be applied in full. #{number_to_currency(extra/100.0)} remain on the ticket."

	# 			elsif value.to_i > total.to_i
	# 				extra = value.to_i - total.to_i
	# 				text = "Gift Value exceeds the ticket value. #{number_to_currency(extra/100.0)} remain on the gift."
	# 				value = total.to_i
	# 			else
	# 				text = "Gift value matched Ticket value, transaction completed."
	# 			end

	# 			tic_id = tic["id"]
	# 			payload = {
	# 			  "type" => "gift_card",
	# 			  "amount" => value,
	# 			  "tip" => 0,
	# 			  "card_info" => {
	# 			    "number" => "#{gift_card_id}" 		# String, Required gift card number, as a string.
	# 			  }
	# 			}.to_json

	# 			response = RestClient.post(
	# 			    "#{POSITRONICS_API_URL}/locations/#{pos_merchant_id}/tickets/#{tic_id}/payments/",
	# 			    payload,
	# 			    {:content_type => :json, :'Api-Key' => POSITRONICS_API_KEY }
	# 			)
	# 			resp = JSON.parse response

	# 			# resp --- what are the conditions here

	# 		else
	# 			error = "Ticket Number #{ticket_num} has already been paid."
	# 		end
	# 	else
	# 		error = "No Ticket was found for ticket number #{ticket_num}"
	# 	end
	# 	return { "error" => error, text => "text"}
	# end

	# def create
	# 	payload = {
	# 		"employee" => "BdTaKT4X",
	# 		"order_type" => "KxiAaip5",
	# 		"revenue_center" => "LdiqGibo",
	# 		"table" => "x4TdoTd8",
	# 		"guest_count" => 1,
	# 		"name" => "ItsOnMe ticket",
	# 		"auto_send" => true
	# 	}.to_json

	# 	response = RestClient.post( "#{POSITRONICS_API_URL}/locations/EaTaa5c6/tickets", payload, {:content_type => :json, :'Api-Key' => POSITRONICS_API_KEY })
	# 	resp_ticket = JSON.parse response


	# 	tic_id = resp_ticket["id"]
	# 	payload = [
	# 		{
	# 		"menu_item" => "recb5cKX",
	# 		"quantity" => 2,
	# 		"price_level" => "Bycnrcdy",
	# 		"comment" => "Burned",
	# 		"modifiers" => []
	# 		},
	# 		{
	# 		"menu_item" => "gki84ia9",
	# 		"quantity" => 1,
	# 		"price_level" => "g4T4dTBj",
	# 		}
	# 	].to_json

	# 	response = RestClient.post("#{POSITRONICS_API_URL}/locations/EaTaa5c6/tickets/#{tic_id}/items", payload, {:content_type => :json, :'Api-Key' => POSITRONICS_API_KEY})
	# 	resp = JSON.parse response
	# end


end