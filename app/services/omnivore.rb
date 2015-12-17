require 'rest_client'

class Omnivore
	extend OmnivoreUtils
	include ActionView::Helpers::NumberHelper

	attr_accessor :response, :code, :pos_merchant_id, :applied_value, :ticket_num, :ticket_id, :check_value, :brand_card, :brand_card_ids, :loc_id, :tender_type_id

	def initialize args
		puts "Omnivore args = #{args.inspect}"

		if  args['brand_card_ids_ary'].nil? || args['brand_card_ids_ary'].length == 0
			@brand_card = false
			@brand_card_ids  = []
		else
			@brand_card = true
			@brand_card_ids = args['brand_card_ids_ary']
		end

		@ticket_num      = strip_leading_zeros args["ticket_num"].to_s
		@ticket_id       = nil
		@gift_card_id    = args["gift_card_id"]
		@pos_merchant_id = args["pos_merchant_id"]
		@loc_id 		 = args["pos_merchant_id"]
		@tender_type_id  = args["tender_type_id"]
		@value           = args["value"].to_i
		@code 		     = 100
		@extra_value     = 0
		@extra_gift      = 0
		@applied_value   = 0
		@check_value 	 = 0
  		@response        = response_from_code
		@next 			 = nil
		@brand_card_applied = false
	end

	def strip_leading_zeros str
		str.match(/^[0-9]*$/) ? str.to_i.to_s : str
	end

	def success?
		(200..299).cover?(@code)
	end

	# def direct_redeem
	# 	@ticket_id = @ticket_num
	# 	if @brand_card
	# 		brand_card_ids = get_brand_card_ids_from_pos
	# 		brand_card_ids.each do |pos_id|
	# 			@brand_card_ids.include?(pos_id)
	# 			@brand_card_applied = true
	# 			break
	# 		end
	# 		if @brand_card_applied
	# 			resp = post_redeem
	# 		else
	# 			# BAD brand card message
	# 		end
	# 	else
	# 		resp = post_redeem
	# 	end
	# end

	def redeem
		tic = nil
		tix = formulate_tickets_at_location

		if tix.class == Array
			tic = get_ticket_from_tix(tix)
		end

		if tic.nil?
			puts "Omnivore tix when no tic #{tix.inspect}"
			if tix.respond_to?(:to_i) && tix.to_i > 399
				@code = tix
			else
				@code = 404
			end
		else
			if tic["closed_at"].nil?
				@ticket_id = tic["id"]

				if @brand_card
					# fail brand card in advance
					@code = 401
					parent_item_ary = tic['_embedded']['items']
					parent_item_ary.each do |p_item|
						if p_item['_embedded']['menu_item'] && p_item['_embedded']['menu_item']['id'] && @brand_card_ids.include?(p_item['_embedded']['menu_item']['id'])
							# success brand card
							if @brand_card_applied == false
								@brand_card_applied = true
								apply_ticket_value tic
							end
						end
					end
				else
					apply_ticket_value tic
				end
			else
				@code = 304
			end
		end

		return @response = response_from_code
	end

	def apply_ticket_value tic
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
		puts "Here is the post_redeem response"
		puts resp.inspect

		case resp
		when "pos-merchant_id incorrect"
			@code = 509
			@applied_value	= 0
		when "server_missing"
			@code = 500
			@applied_value	= 0
		when "The point of sale rejected the request"
			@code = 503
			@applied_value	= 0
		end

		if !resp.kind_of?(Hash) && resp.to_i > 399
			@code = resp.to_i
			@applied_value = 0
		end
	end

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
		when 400
			r_code = "ERROR"
			r_text = "Internal Error Point of Sale System Unavailable. Please try again later or contact support@itson.me"
		when 404
			r_code = "ERROR"
			r_text = "Your check number #{@ticket_num} cannot be found. Please double check and try again. If this issue persists please contact support@itson.me"
		when 401
			r_code = "ERROR"
			r_text = "This gift card is only redeemable for the exact item mentioned. Please order the correct item to use this gift card."
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
		{ "response_code" => r_code, "response_text" => response_data }
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

		puts "\nOmnivore payload:\n"
		puts payload.inspect

		begin
			response = RestClient.post(
			    "#{POSITRONICS_API_URL}/locations/#{@pos_merchant_id}/tickets/#{@ticket_id}/payments/",
			    payload,
			    {:content_type => :json, :'Api-Key' => POSITRONICS_API_KEY }
			)
			r = JSON.parse(response)
			# puts r.inspect
			r
		rescue => e
			puts "\n\n POSITRONICS ERROR #{e.inspect}"
			e
			unless e.nil?
				resp = e.response.code
				puts "\n\nOmnivore Error code = #{resp}\n #{e.inspect}\n #{response.inspect}\n"
				puts " Error Hash == " + { "code" => e.response.code, "error" => e.response['error']}.inspect
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
				puts "\n\nOmnivore Error code = #{resp}\n\n"
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
				puts "\n\nOmnivore Error code = #{resp}\n\n"
				resp
			end

		end
	end

    def get resource=:locations, obj_id=@pos_merchant_id, meth=nil
    	obj_id = obj_id.present? ? (obj_id + "/") : ''

        begin
            response = RestClient.get(
                "#{POSITRONICS_API_URL}/#{resource}/#{obj_id}#{meth}",
                {:content_type => :json, :'Api-Key' =>  POSITRONICS_API_KEY }
            )
            r = JSON.parse(response)
            # puts r.inspect + "\n ^^^ utils get"
            @code = 200
            @response = { "response_code" => "SUCCESS", "response_text" => "#{resource}/#{obj_id}#{meth}", "status" => 200, "data" => r }
            r
        rescue => e
            puts "\n\n POSITRONICS ERROR #{e.inspect}"
            unless e.nil?
                resp = e.response.code
                @code = resp
                puts "\n\nOmnivore Error code = #{resp}\n #{e.inspect} \n#{e.response}\n"
                @response = { "response_code" => "ERROR", "response_text" => e.response['error'], "status" => @code, "data" => [] }
            end
            e
        end

    end

    def tickets(loc_id, next_link=nil)
    	hsh = {}
    	tag = "tickets"
    	tag += next_link.split('tickets')[1] if next_link.present?
    	resp = get(:locations, loc_id, tag)
    	tics = resp["_embedded"]["tickets"]
    	if tics.kind_of?(Array)
    		hsh["tickets"] = tics#.map { |t| PosTicket.new t }
	    	if resp["_links"]["next"].present?
	    		hsh["next"] = resp["_links"]["next"]["href"]
	    	end
	    	if resp["_links"]["prev"].present?
	    		hsh["prev"] = resp["_links"]["prev"]["href"]
	    	end
    	else
    		hsh["error"] = "Error"
    		hsh["tickets"] = []
    	end
    	hsh
    end

    def get_ticket(ticked_id_added=nil)
    	ticket_uniq = ticked_id_added || @ticked_id || @ticket_num
    	get('locations',@pos_merchant_id, "tickets/#{ticket_uniq}" )
    end

    def brand_card_good(raw_ticket)
    	items = raw['_embedded']['items']
    	brand_card_ids_ary = items.map do |item_raw|
    		item_raw['_embedded']['menu_item']['id']
    	end
    end

    def get_brand_card_ids_from_pos(ticked_id_added=nil)
    	raw = get_ticket(ticked_id_added)
    	items = raw['_embedded']['items']

    	brand_card_ids_ary = items.map do |item_raw|
    		item_raw['_embedded']['menu_item']['id']
    	end
    	brand_card_ids_ary
    end

	def menu_items
		r = get('locations', @pos_merchant_id, "menu/items")
		puts "\n here is the response"
		puts r.inspect
		if @code == 200
	        items =  r["_embedded"]["menu_items"].map do |m|
	        	if m['price'].to_i > 0
		            mi = { name: m["name"], price: m["price"], pos_menu_item_id: m["id"] }
		            puts "\nhere #{mi.inspect}"
		            mi
		        else
		        	nil
		        end
	        end
	        @response['data'] = items.compact.sort_by{|item| item[:name].downcase }
	    else
	    	@response
	    end
	end

end


# Rack::Timeout::RequestTimeoutException (Request waited 0ms, then ran for longer than 19000ms):
#   app/services/omnivore.rb:216:in `post_redeem'
#   app/services/omnivore.rb:123:in `apply_ticket_value'
# [0ce1fc67-ba95-4aba-af57-690cca04d96f] Completed 500 Internal Server Error in 18999ms (ActiveRecord: 9.8ms)
#   app/services/omnivore.rb:97:in `redeem'
#   app/models/concerns/gift_lifecycle.rb:110:in `pos_redeem'
#   app/controllers/mdot/v2/gifts_controller.rb:84:in `pos_redeem'