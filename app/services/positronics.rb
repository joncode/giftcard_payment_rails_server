require 'rest_client'

class Positronics
	extend PositronicsUtils
	include ActionView::Helpers::NumberHelper

	attr_reader :response, :code, :applied_value, :ticket_num, :ticket_id, :check_value

	def initialize args
		puts "Positronics args = #{args.inspect}"
		@ticket_num      = args["ticket_num"].to_s
		@ticket_id       = nil
		@gift_card_id    = args["gift_card_id"]
		@pos_merchant_id = args["pos_merchant_id"]
		@tender_type_id  = args["tender_type_id"]
		@value           = args["value"].to_i
		@code 		     = 100
		@extra_value     = 0
		@extra_gift      = 0
		@applied_value   = 0
		@check_value 	 = 0
  		@response        = response_from_code
		@next 			 = nil
	end

	def success?
		(200..299).cover?(@code)
	end

	def redeem
		tic = nil
		tix = formulate_tickets_at_location

		if tix.class == Array
			tic = get_ticket_from_tix(tix)
		end

		if tic.nil?
			if tix.to_i > 400
				@code = tix
			else
				@code = 404
			end
		else
			if tic["closed_at"].nil?
				@ticket_id = tic["id"]
				@check_value = tic["totals"]["due"].to_i

				if @value < @check_value
					@code			= 206   # ok , the gift has partially covered the ticket cost
					@extra_value	= @check_value - @value
					@applied_value	= @value
				elsif @value > @check_value
					@code			= 201    # ok , a new gift has been created for the extra gift value
					@extra_gift	    = @value - @check_value
					@applied_value	= @check_value
				else
					@code  = 200   # ok , full aceeptance
					@applied_value	= @value
				end

				resp = post_redeem
				puts resp.inspect
				case resp
				when "pos-merchant_id incorrect"
					@code = 509
					@applied_value	= 0
				when "server_missing"
					@code = 500
					@applied_value	= 0
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

# private

	def response_from_code
		case @code
		when 100
			r_code = "OPEN"
			r_text = "Gift has not been redeemed yet."
		when 200
			r_code = "PAID"
			r_text = "#{number_to_currency(@value/100.0)} was applied to your check. Transaction completed."
		when 201
			r_code = "OVER_PAID"
			r_text = "Your gift exceeded the check value. Your gift has a balance of #{number_to_currency(@extra_gift/100.0)}."
		when 206
			r_code = "APPLIED"
			r_text = "#{number_to_currency(@value/100.0)} was applied to your check. A total of #{number_to_currency(@extra_value/100.0)} remains to be paid."
		when 304
			r_code = "ERROR"
			r_text = "Check Number #{@ticket_num} has already been paid."
		when 404
			r_code = "ERROR"
			r_text = "Your check number #{@ticket_num} cannot be found. Please double check and try again. If this issue persists please contact support@itson.me"
		when 500
			r_code = "ERROR"
			r_text = "Internal Error Point of Sale System Unavailable. Please try again later or contact support@itson.me"
		when 503
			r_code = "ERROR"
			r_text = "Merchant Point of Sale System Unavailable.  Please try again after a few minutes."
		when 509
			r_code = "ERROR"
			r_text = "Merchant Server Unavailable.  Please try again later."
		else
			r_code = "ERROR"
			r_text = "Server Error.  Please try again later"
		end
		if success?
			hsh = success_hsh
			hsh[:msg] = r_text
			response_data = hsh
		else
			response_data = r_text
		end
		{ "response_code" => r_code, "response_text" => response_data}
	end

	def success_hsh
		{
            amount_applied: @applied_value,
            total_check_amount: @check_value,
            remaining_check_balance: @extra_value,
            remaining_gift_balance: @extra_gift
		}
	end

	def post_redeem
		payload = {
		  "type" => "3rd_party",
		  "amount" => @applied_value,
		  "tip" => 0,
		  "tender_type" => @tender_type_id,
  		  "payment_source" => "Gift #{@gift_card_id}"
		}.to_json

		puts "\nPositronics look after:\n"
		puts payload.inspect

		begin
			response = RestClient.post(
			    "#{POSITRONICS_API_URL}/locations/#{@pos_merchant_id}/tickets/#{@ticket_id}/payments/",
			    payload,
			    {:content_type => :json, :'Api-Key' => POSITRONICS_API_KEY }
			)
			r = JSON.parse(response)
			puts r.inspect
			r
		rescue => e
			puts "\n\n POSITRONICS ERROR #{e.inspect}"
			e
			unless e.nil?
				resp = e.response.code
				puts "\n\nPositronics Error code = #{resp}\n #{e.inspect}\n #{response.inspect}\n"
				resp
			end
		end
	end

	def get_ticket_from_tix(tix)
		found_it = nil
		found_it = tix.select { |t| t["ticket_number"].to_s == @ticket_num }.first
		if found_it.nil? && @next.present?
			tix = get_paginated_tickets
			if tix.class == Array
				found_it = get_ticket_from_tix(tix)
			end
		end
		found_it
	end

	def get_paginated_tickets
		@next = @next.split('tickets/')[1]
		begin
			puts @next.inspect
			response = RestClient.get(
			    "#{POSITRONICS_API_URL}/locations/#{@pos_merchant_id}/tickets/#{@next}",
			    {:content_type => :json, :'Api-Key' => POSITRONICS_API_KEY }
			)
			resp = JSON.parse(response)
			if resp.kind_of?(Hash) && resp["_embedded"].present? && resp["_embedded"]["tickets"].present?
				if resp["_links"] && resp["_links"]["next"]
					@next = resp["_links"]["next"]["href"]
				else
					@next = nil
				end
				resp["_embedded"]["tickets"]
			else
				resp
			end
		rescue => e
			puts "\n\n POSITRONICS ERROR #{e.inspect}"
			e
			unless e.nil?
				resp = e.response.code
				puts "\n\nPositronics Error code = #{resp}\n\n"
				resp
			end
		end
	end

	def formulate_tickets_at_location
		@next = nil
		resp  = get_tickets_at_location
		if resp.kind_of?(Hash) && resp["_embedded"].present? && resp["_embedded"]["tickets"].present?
			if resp["_links"].present? && resp["_links"]["next"].present?
				@next = resp["_links"]["next"]["href"]
			end
			resp["_embedded"]["tickets"]
		else
			resp
		end
	end

	def get_all_tickets_at_location
		begin
			response = RestClient.get(
			    "#{POSITRONICS_API_URL}/locations/#{@pos_merchant_id}/tickets",
			    {:content_type => :json, :'Api-Key' => POSITRONICS_API_KEY }
			)
			JSON.parse(response)
		rescue => e
			puts "\n\n POSITRONICS ERROR #{e.inspect}"
			e
			unless e.nil?
				resp = e.response.code
				puts "\n\nPositronics Error code = #{resp}\n\n"
				resp
			end

		end
	end

	def get_tickets_at_location
		begin
			response = RestClient.get(
			    "#{POSITRONICS_API_URL}/locations/#{@pos_merchant_id}/tickets?where=eq(open,true)",
			    {:content_type => :json, :'Api-Key' => POSITRONICS_API_KEY }
			)
			JSON.parse(response)
		rescue => e
			puts "\n\n POSITRONICS ERROR #{e.inspect}"
			e
			unless e.nil?
				resp = e.response.code
				puts "\n\nPositronics Error code = #{resp}\n\n"
				resp
			end

		end
	end
end